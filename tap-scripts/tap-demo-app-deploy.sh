#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf

echo "Build source code in build cluster !!!"

echo "Login to build cluster !!!"
aws eks --region $aws_region update-kubeconfig --name tap-build

echo "delete existing app"
tanzu apps workload delete --all

tanzu apps workload list


tanzu apps workload create "${TAP_APP_NAME}" \                                                                                                                             ok | 03:47:58 PM 
--git-repo "${TAP_APP_GIT_URL}" \
--git-branch tap1.3 \
--type web \
--label app.kubernetes.io/part-of="${TAP_APP_NAME}" \
--yes --dry-run > ${TAP_APP_NAME}-workload.yaml


tanzu apps workload create "${TAP_APP_NAME}" \                                                                                                                             ok | 03:47:58 PM 
--git-repo "${TAP_APP_GIT_URL}" \
--git-branch tap1.3 \
--type web \
--label app.kubernetes.io/part-of="${TAP_APP_NAME}" \
--yes


#tanzu apps workload create spring-music \                                                                                                                             ok | 03:47:58 PM 
#--git-repo https://github.com/PeterEltgroth/spring-music \
#--git-branch tap1.3 \
#--type web \
#--label app.kubernetes.io/part-of=spring-music \
#--yes

sleep 10

tanzu apps workload list

tanzu apps workload get "${TAP_APP_NAME}"

echo "generate tap-demo deliver.yaml workload "

kubectl get deliverables "${TAP_APP_NAME}" -o yaml |  yq 'del(.status)'  | yq 'del(.metadata.ownerReferences)' | yq 'del(.metadata.resourceVersion)' | yq 'del(.metadata.uid)' >  "${TAP_APP_NAME}-delivery.yaml"

cat ${TAP_APP_NAME}-delivery.yaml

echo "login to run cluster to deploy tap demo delivery workload"
aws eks --region $aws_region update-kubeconfig --name tap-run

kubectl apply -f ${TAP_APP_NAME}-delivery.yaml

kubectl get deliverable -A     

echo "get app url and copy into browser to test the app"
kubectl get ksvc



