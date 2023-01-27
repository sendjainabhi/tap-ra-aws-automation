#!/bin/bash
source var.conf
export TAP_APP_NAME=tanzu-java-web-app
echo "Build source code in build cluster !!!"

echo "Login to build cluster !!!"
aws eks --region $aws_region update-kubeconfig --name tap-build

tanzu apps workload list

echo "delete existing app"

tanzu apps workload delete ${TAP_APP_NAME} --yes




tanzu apps workload create tanzu-java-web-app \
--git-repo https://github.com/vmware-tanzu/application-accelerator-samples \
--sub-path tanzu-java-web-app \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=tanzu-java-web-app \
--yes \
--namespace ${TAP_DEV_NAMESPACE}


#tanzu apps workload tail tanzu-java-web-app --since 3m --timestamp --namespace ${TAP_DEV_NAMESPACE}
echo "Waiting for app build !!!! "
sleep 50


tanzu apps workload get "${TAP_APP_NAME}"

echo "generate tap-demo deliver.yaml workload "

kubectl get configmap tanzu-java-web-app-deliverable -n ${TAP_DEV_NAMESPACE} -o go-template='{{.data.deliverable}}' > ${TAP_APP_NAME}-delivery.yaml

cat ${TAP_APP_NAME}-delivery.yaml

echo "login to run cluster to deploy tap demo delivery workload"
aws eks --region $aws_region update-kubeconfig --name tap-run

kubectl apply -f ${TAP_APP_NAME}-delivery.yaml

kubectl get deliverable -A   

kubectl get httpproxy --namespace ${DEVELOPER_NAMESPACE}

sleep 15
echo "get app url and copy into browser to test the app"
kubectl get ksvc



