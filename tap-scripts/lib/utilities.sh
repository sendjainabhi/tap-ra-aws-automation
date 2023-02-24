#!/bin/bash

get_kubeconfig(){
  if ! $1; then
    if [ -z "$cluster_name" ]; then
      echo "Use cluster_name: $cluster_name"
      cluster=$cluster_name
    else
      echo "No cluster name passed or defaulted with cluster_name"
    fi
  else
    cluster=$1
  fi

  if [ -z "$2" ]; then
    if [ -z "$aws_region" ]; then
      echo "Use aws_region: $aws_region"
      region=$aws_region
    else
      echo "No cluster name passed or defaulted with cluster_name"
    fi
  else
    region=$2
  fi

  echo ""
  echo "Get kubeconfig for $cluster in $region"
  aws eks --region $region update-kubeconfig --name $cluster
}

cluster_login(){
  echo ""
  echo "Login to $cluster_name in $aws_region"
  aws eks --region $aws_region update-kubeconfig --name $cluster_name
  # This can be enhanced `use-context` if the cluster config is already in kube/config 
  # echo "Using Kubernetes context: arn:aws:eks:${aws_region}:${aws_account_id}:cluster/${cluster_name}"
  # kubectl config use-context "arn:aws:eks:${aws_region}:${aws_account_id}:cluster/${cluster_name}"
}
