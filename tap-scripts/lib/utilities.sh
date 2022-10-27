#!/bin/bash

cluster_login(){
  echo ""
  echo "Login to $cluster_name in $aws_region"
  aws eks --region $aws_region update-kubeconfig --name $cluster_name
  # echo "Using Kubernetes context: arn:aws:eks:${aws_region}:${aws_account_id}:cluster/${cluster_name}"
  # kubectl config use-context "arn:aws:eks:${aws_region}:${aws_account_id}:cluster/${cluster_name}"
}
