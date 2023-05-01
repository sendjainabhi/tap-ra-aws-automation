#!/bin/bash
source var.conf

TAP_APP_NAME=spring-music 

echo "Build source code in build cluster !!!"

echo "Login to build cluster !!!"
aws eks --region $aws_region update-kubeconfig --name tap-build

tanzu apps workload list

echo "delete existing app"
tanzu apps workload delete ${TAP_APP_NAME} --yes


tanzu apps workload create spring-music \
--git-repo https://github.com/PeterEltgroth/spring-music \
--git-branch tap1.3 \
--type web \
--label app.kubernetes.io/part-of=spring-music \
--yes


sleep 40

tanzu apps workload list

tanzu apps workload get "${TAP_APP_NAME}"

echo "generate tap-demo deliver.yaml workload "

kubectl get configmap ${TAP_APP_NAME}-deliverable -n ${TAP_DEV_NAMESPACE} -o go-template='{{.data.deliverable}}' > ${TAP_APP_NAME}-delivery.yaml

cat ${TAP_APP_NAME}-delivery.yaml

echo "login to run cluster to deploy tap demo delivery workload"
aws eks --region $aws_region update-kubeconfig --name tap-run

kubectl apply -f ${TAP_APP_NAME}-delivery.yaml

kubectl get deliverable -A     
sleep 15
echo "get app url and copy into browser to test the app"
kubectl get ksvc



