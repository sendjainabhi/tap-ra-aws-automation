#!/bin/bash
chmod +x *.sh

usage(){
  echo "Usage: tap-cluster.sh"
  echo ""
  echo "Pre-requisites:"
  echo "  A EKS clsuter"
  echo "  kubectl CLI: https://kubernetes.io/docs/tasks/tools/"
  echo "  aws CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  echo "  eksctl CLI: https://eksctl.io/introduction/#installation"
  echo ""
  echo "Parameter:"
  echo "  -c <cluster_name>"
  echo "     Must be one of tap-view, tap-run, tap-build, tap-iterate"
  echo ""
  echo "Example:"
  echo "tap-cluster.sh -c tap-view"
  echo ""
}

check_tooling(){
  check_for_kubectl
  check_for_aws
  check_for_eksctl
  check_for_awk
}

input_validation(){
  if [ -z "$cluster_name" ]; then
    echo "ERROR: cluster_name must be provided with -c"
    echo ""
    usage
    exit 1
  fi
}

main(){
  source lib/check-tools.sh
  source lib/utilities.sh
  check_tooling

  cluster_name=""
  source var.conf
  ./var-input-validatation.sh

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

  echo "Step 1 => Install EKS EBS CSI Driver if K8s version 1.23 or newer"
  ./eks-csi.sh -c $cluster_name

  echo "Step 2 => Install tanzu cli and tanzu essential in $cluster_name cluster"
  ./tanzu-essential-setup.sh

  echo "Step 3 => Install TAP Repo in $cluster_name cluster"
  ./tap-repo.sh

  echo "Step 4 => Install TAP Profile for $cluster_name cluster"
  case "$cluster_name" in
    tap-view)
      echo "Run tap-view-profile.sh"
      ./tap-view-profile.sh
      ;;
    tap-run)
      echo "Run tap-run-profile.sh"
      ./tap-run-profile.sh
      ;;
    tap-build)
      echo "Run tap-build-profile.sh"
      ./tap-build-profile.sh
      ;;
    tap-iterate)
      echo "Run tap-iterate-profile.sh"
      ./tap-iterate-profile.sh
      ;;
    *)
      echo "Error: Invalid cluster_name $cluster_name, must be one of tap-view, tap-run, tap-build, tap-iterate" >&2
      exit 1
      ;;    
  esac

  echo "Step 5 => Install TAP developer namespace in $cluster_name cluster"
  ./tap-dev-namespace.sh
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  main "$@"
fi
