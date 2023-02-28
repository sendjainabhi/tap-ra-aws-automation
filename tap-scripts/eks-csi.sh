#!/bin/bash
# set -e

usage(){
  echo "Usage: eks-csi-setup.sh "
  echo ""
  echo "Pre-requisites:"
  echo "  A EKS clsuter"
  echo "  A logged in aws CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  echo "  eksctl CLI: https://eksctl.io/introduction/#installation"
  echo "  kubectl CLI: https://kubernetes.io/docs/tasks/tools/"
  echo ""
  echo "Parameters:"
  echo "  -c <cluster_name>"
  echo "  -r <region>"
  echo "    Typically sourced from var.conf"
  echo "    Providing here will override the var.conf value"
  echo ""
  echo "Examples:"
  echo "eks-csi-setup.sh -c tap-view"
  echo "eks-csi-setup.sh -c tap-view --remove"
  echo ""
}

cluster_login(){
  echo ""
  echo "Login to $cluster_name in $aws_region"
  aws eks --region $aws_region update-kubeconfig --name $cluster_name
  # This can be enhanced to use `k config use-context` if it is already in kube/config 
  # echo "Using Kubernetes context: arn:aws:eks:${aws_region}:${aws_account_id}:cluster/${cluster_name}"
  # kubectl config use-context "arn:aws:eks:${aws_region}:${aws_account_id}:cluster/${cluster_name}"
}

check_tooling(){
  check_for_kubectl
  check_for_aws
  check_for_eksctl
  check_for_awk
}

input_validation(){
  valid=1

  if [ -z "$aws_region" ]; then
    valid=0
    echo "Error: aws_region must be provided, check var.conf or pass with -r"
  fi

  if [ -z "$aws_account_id" ]; then
    valid=0
    echo "Error: Unable to get aws_account_id with `aws sts get-caller-identity`, check your aws login and connection"
  fi

  if [ -z "$cluster_name" ]; then
    valid=0
    echo "Error: cluster_name must be provided with -c"
  fi

  if [ $valid == 0 ]; then
    exit 1
  fi
}

create_trust_policy(){
  echo "Create Trust Policy json"
cat>aws-ebs-csi-driver-trust-policy-$cluster_name.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${aws_account_id}:oidc-provider/oidc.eks.${aws_region}.amazonaws.com/id/${oidc_id}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${aws_region}.amazonaws.com/id/${oidc_id}:aud": "sts.amazonaws.com",
          "oidc.eks.${aws_region}.amazonaws.com/id/${oidc_id}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF
  cat aws-ebs-csi-driver-trust-policy-$cluster_name.json
}

get_oidc(){
  # Every cluster has it's own oidc.issuer
  oidc_issuer_url=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text)

  if [ -z "$oidc_issuer_url" ]; then
    echo "Error: Unable to get oidc_id from 'aws eks' for $cluster_name"
    exit 1
  fi

  echo "oidc_issuer_url: $oidc_issuer_url"
  oidc_id=$(echo $oidc_issuer_url | awk -F '/' '{print $NF}')
  oidc_arn="arn:aws:iam::${aws_account_id}:oidc-provider/oidc.eks.${aws_region}.amazonaws.com/id/${oidc_id}"
  echo "Cluster $cluster_name oidc_arn: $oidc_arn"
}

remove_csi(){
  echo "Check if EBS CSI Driver is installed for cluster: $cluster_name"
  if [[ -z $(aws eks list-addons --cluster-name $cluster_name --no-cli-pager | jq -r '.addons[]' | grep "aws-ebs-csi-driver") ]]; then
    echo "EBS CSI Driver is currently not installed"
  else
    echo "EBS CSI Driver is installed, removing..."
    echo "Detach IAM role from AWS managed policy"
    aws iam detach-role-policy \
      --role-name AmazonEKS_EBS_CSI_DriverRole_$cluster_name \
      --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
      
    echo "Delete IAM role"
    aws iam delete-role \
      --role-name AmazonEKS_EBS_CSI_DriverRole_$cluster_name
    
    echo "Delete OIDC Connect Provider for arn: $oidc_arn"
    aws iam delete-open-id-connect-provider --open-id-connect-provider-arn $oidc_arn

    echo "Delete aws-ebs-csi-driver addon"
    aws eks delete-addon \
      --cluster-name $cluster_name \
      --addon-name aws-ebs-csi-driver \
      --no-cli-pager 
    # --preserve 
    # preserves the add-on software on your cluster (ebs-csi-controller and ebs-csi-controller-sa)
    # but Amazon EKS stops managing any settings for the add-on. 
    # If an IAM account is associated with the add-on, it isn't removed.

    for (( i=0; i<10; i++ ))
    do
      echo "Deletion may take time, sleeping: " $((($i + 1)*3))
      sleep 3
      if [[ -z $(kubectl -n kube-system get deployments.apps | grep ebs-csi-controller) ]]; then
        echo "Deleted aws-ebs-csi-driver addon"
        echo ""
        break
      fi
    done
  fi
}

add_csi(){
  #https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html
  get_oidc

  # Creating an IAM OIDC provider for your cluster 
  # https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
  if [[ -z $(aws iam list-open-id-connect-providers | grep $oidc_id) ]]; then
    echo "Creating IAM OIDC provider for $cluster_name"
    eksctl utils associate-iam-oidc-provider --region $aws_region --cluster $cluster_name --approve

  fi

  # Creating the Amazon EBS CSI driver IAM role for service accounts 
  # https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
  create_trust_policy

  echo "Create AmazonEKS_EBS_CSI_DriverRole_$cluster_name"
  aws iam create-role \
    --role-name AmazonEKS_EBS_CSI_DriverRole_$cluster_name \
    --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy-$cluster_name.json" \
    --no-cli-pager
    
  echo "Attach Role to the AWS managed Policy AmazonEBSCSIDriverPolicy"
  # https://docs.aws.amazon.com/eks/latest/userguide/security-iam-awsmanpol.html#security-iam-awsmanpol-AmazonEBSCSIDriverServiceRolePolicy
  aws iam attach-role-policy \
    --role-name AmazonEKS_EBS_CSI_DriverRole_$cluster_name \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
    
  # The Amazon EBS CSI add-on installs the 'ebs-csi-controller' Deployment and creates the 'ebs-csi-controller-sa' ServiceAccount
  # https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html#adding-ebs-csi-eks-add-on
  echo "Create EKS addon for aws-ebs-csi-driver"
  aws eks create-addon \
    --cluster-name $cluster_name \
    --addon-name aws-ebs-csi-driver \
    --service-account-role-arn "arn:aws:iam::${aws_account_id}:role/AmazonEKS_EBS_CSI_DriverRole_$cluster_name" \
    --tags cluster=$cluster_name --no-cli-pager
}

main(){
  source lib/check-tools.sh
  check_tooling

  cluster_name=""
  aws_region=""
  aws_account_id=""

  source var.conf
  aws_account_id=$(aws sts get-caller-identity --query "Account" --output text --no-cli-pager)

  while (( "$#" )); do
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
        -c) 
          shift
          cluster_name=$1
          echo "Input cluster_name: $cluster_name"
          ;;
        -r) 
          shift
          aws_region=$1
          echo "Input aws_region: $aws_region"
          ;;
        --remove)
          cluster_login
          get_oidc
          remove_csi
          exit 0
          ;;
        -*)
          echo "Unsupported flag $1" >&2
          usage
          exit 1
          ;;
        *)
          echo "Invalid input" >&2
          usage
          exit 1
          ;;
      esac
      shift
    done

  echo "Using cluster_name: $cluster_name"
  echo "Using aws_region: $aws_region"
  echo "Using aws_account_id: $aws_account_id"

  input_validation
  echo "cluster_login: $cluster_name in $aws_region"
  cluster_login

  if [[ $(aws eks describe-cluster --name $cluster_name --query "cluster.version" --output text) < '1.23' ]]; then
    echo "EKS Kubernetes version is less than 1.23, not installing CSI Driver Plugin. See https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html"
    exit 0
  fi

  if [[ -z $(aws eks list-addons --cluster-name $cluster_name --no-cli-pager | jq -r '.addons[]' | grep "aws-ebs-csi-driver") ]]; then
    echo "EBS CSI Driver is not installed, installing..."
    add_csi
  else
    echo "EBS CSI Driver already installed for cluster: $cluster_name"
  fi
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  main "$@"
fi
