#!/bin/bash

CLUSTER_NAME_PREFIX=$1

for PROFILE in view run iterate build 
do
	echo "extracting certificates and keys from $i kubeconfig file"
	cat kubeconfig${CLUSTER_NAME_PREFIX}${PROFILE}.txt | yq '.clusters[0].cluster.certificate-authority-data' | base64 -d > tap-${PROFILE}-cacert.pem
	cat kubeconfig${CLUSTER_NAME_PREFIX}${PROFILE}.txt | yq '.users[0].user.client-certificate-data' | base64 -d > tap-${PROFILE}-cert.pem
	cat kubeconfig${CLUSTER_NAME_PREFIX}${PROFILE}.txt | yq '.users[0].user.client-key-data' | base64 -d > tap-${PROFILE}-cert.key
done

