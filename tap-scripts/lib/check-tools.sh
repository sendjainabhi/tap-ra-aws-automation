#!/bin/bash
set -e

check_for_awk(){
  echo "Checking for awk..."
  if ! command -v awk &> /dev/null; then
    echo "awk is not installed. Please install and try again." >&2
    exit 1
  fi

  awk -version
}

check_for_aws(){
  echo "Checking for aws CLI..."
  if ! command -v aws &> /dev/null; then
    echo "aws is not installed. See https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" >&2
    exit 1
  fi

  aws  --v
}

check_for_eksctl(){
  echo "Checking for eksctl CLI..."
  if ! command -v eksctl &> /dev/null; then
    echo "eksctl is not installed. See https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html"
    echo "Installing eksctl"
    echo "Downlaoding: https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_$(uname -m).tar.gz"
    curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_$(uname -m).tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin/eksctl
  fi
  
  eksctl  version
}

check_for_kubectl(){
  echo "Checking for kubectl CLI..."
  if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. See https://kubernetes.io/docs/tasks/tools/" >&2
    exit 1
  fi

  echo "kubectl clientVersion version"
  kubectl version -ojson | jq '.clientVersion' -r
}

check_for_tanzu(){
  echo "Checking for tanzu CLI..."
  if ! command -v tanzu &> /dev/null; then
    echo "tanzu CLI not installed. Please install tanzu CLI and start again." >&2
    exit 1
  fi

  tanzu version
  printf "Done\n\n"
}

check_for_terraform(){
  echo "Checking for terraform CLI..."
  if ! command -v terraform  &> /dev/null; then
    echo "terraform is not installed. See https://www.terraform.io/downloads.html" >&2
    exit 1
  fi

  terraform version
}

check_all_tools(){
  check_for_awk
  check_for_aws
  check_for_eksctl
  check_for_kubectl
  check_for_tanzu
  check_for_terraform
}