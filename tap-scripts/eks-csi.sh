#!/bin/bash

usage(){
  echo "Usage: eks-csi-setup.sh "
  echo ""
  echo "Pre-requisites:"
  echo "  A EKS clsuter"
  echo "  kubectl CLI: https://kubernetes.io/docs/tasks/tools/"
  echo "  aws CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  echo "  eksctl CLI: https://eksctl.io/introduction/#installation"
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
cat>aws-ebs-csi-driver-trust-policy.json <<EOF
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
  cat aws-ebs-csi-driver-trust-policy.json
}

get_oidc_info(){
  oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | awk -F '/' '{print $NF}')

  if [ -z "$oidc_id" ]; then
    echo "Error: Unable to get oidc_id from `aws eks`"
    exit 1
  fi

  oidc_arn="arn:aws:iam::${aws_account_id}:oidc-provider/oidc.eks.${aws_region}.amazonaws.com/id/${oidc_id}"
}

remove_csi(){
  echo "Removing EBS CSI Driver from cluster, if it is not installed expect not found errors"
  echo "Detach IAM role and policy"
  aws iam detach-role-policy \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
    
  echo "Delete IAM role"
  aws iam delete-role \
    --role-name AmazonEKS_EBS_CSI_DriverRole

  echo "Delete OIDC Connect Provider for arn: $oidc_arn"
  aws iam delete-open-id-connect-provider --open-id-connect-provider-arn $oidc_arn

  # On MacOS this cmd lands in `less` to display json pausing execution and requireding 'q' to be pressed to continue
  echo "Delete aws-ebs-csi-driver addon"
  aws eks delete-addon \
    --cluster-name $cluster_name \
    --addon-name aws-ebs-csi-driver \
    --no-cli-pager  # Prevent cmd output from going to 'less'

  # Sometimes the create starts before this is finished in AWS
  for (( i=0; i<10; i++ ))
  do
    sleep 1
    if [[ -z $(aws iam list-open-id-connect-providers | grep $oidc_id) ]]; then
      echo "Deleted aws-ebs-csi-driver addon"
      echo ""
      break
    fi
  done
}

main(){
  source lib/check-tools.sh
  source lib/utilities.sh
  check_tooling

  cluster_name=""
  aws_region=""
  aws_account_id=""

  source var.conf
  aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)

  while (( "$#" )); do
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
        -c) 
          shift
          cluster_name=$1
          echo "cluster_name: $cluster_name"
          ;;
        -r) 
          shift
          aws_region=$1
          echo "aws_region: $aws_region"
          ;;
        --remove)
          cluster_login
          get_oidc_info
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

  input_validation
  cluster_login

  if [[ $(aws eks describe-cluster --name $cluster_name --query "cluster.version" --output text) < '1.23' ]]; then
    echo "EKS Kubernetes version is less than 1.23, not installing CSI Driver Plugin. See https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html"
    exit 0
  fi

  get_oidc_info
  remove_csi

  #https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
  #https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html
  echo "Create EKS addon for aws-ebs-csi-driver"
  aws eks create-addon \
    --cluster-name $cluster_name \
    --addon-name aws-ebs-csi-driver \
    --service-account-role-arn "arn:aws:iam::${aws_account_id}:role/AmazonEKS_EBS_CSI_DriverRole" \
    --no-cli-pager  # Prevent cmd output from going to 'less'

  # https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
  if [[ -z $(aws iam list-open-id-connect-providers | grep $oidc_id) ]]; then
    echo "Creating IAM OIDC provider for $cluster_name"
    eksctl utils associate-iam-oidc-provider --region $aws_region --cluster $cluster_name --approve

    # An more complex alternative is using: aws iam create-open-id-connect-provider
    # oidc_issuer_url=$(aws eks describe-cluster --name tap-build --query "cluster.identity.oidc.issuer" --output text)
    # thumbprint=$(aws eks describe-cluster --name tap-build | jq '.cluster.certificateAuthority.data' -r | base64 -d | openssl x509 -fingerprint -noout | awk -F '=' '{print $2}' | sed 's/://g')
    # aws iam create-open-id-connect-provider --url $oidc_issuer_url --thumbprint-list $thumbprint
  fi

  create_trust_policy
  
  echo "Create AmazonEKS_EBS_CSI_DriverRole"
  aws iam create-role \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json" \
    --no-cli-pager  # Prevent cmd output from going to 'less'
    
  echo "Attach Role and Policy"
  aws iam attach-role-policy \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
    
  echo "Annotate ServiceAccount"
  kubectl annotate serviceaccount ebs-csi-controller-sa \
      -n kube-system --overwrite \
      eks.amazonaws.com/role-arn=arn:aws:iam::${aws_account_id}:role/AmazonEKS_EBS_CSI_DriverRole
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  main "$@"
fi
