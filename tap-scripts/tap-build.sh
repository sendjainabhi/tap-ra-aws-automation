#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf

chmod +x tanzu-essential-setup.sh
chmod +x tap-repo.sh
chmod +x tap-build-profile.sh
chmod +x tap-dev-namespace.sh
chmod +x tanzu-cli-setup.sh

chmod +x var-input-validatation.sh

./var-input-validatation.sh

echo  "Login to BUILD Cluster !!! "
kubectl config set-cluster ${TAP_BUILD_CLUSTER_NAME} --server=${TAP_BUILD_CLUSTER_SERVER} --certificate-authority=${TAP_BUILD_CLUSTER_CACERT_FILE}
kubectl config set-credentials ${TAP_BUILD_CLUSTER_USER} --client-certificate=${TAP_BUILD_CLUSTER_CERT_FILE} --client-key=${TAP_BUILD_CLUSTER_KEY_FILE}
kubectl config set-context ${TAP_BUILD_CLUSTER_USER}@${TAP_BUILD_CLUSTER_NAME} --cluster=${TAP_BUILD_CLUSTER_NAME} --user=${TAP_BUILD_CLUSTER_USER}
kubectl config use-context ${TAP_BUILD_CLUSTER_USER}@${TAP_BUILD_CLUSTER_NAME}

#echo "Step 1 => installing tanzu essential in BUILD Cluster !!!"
#./tanzu-essential-setup.sh
echo "Step 2 => installing TAP Repo in BUILD Cluster !!! "
./tap-repo.sh
echo "Step 3 => installing TAP Build Profile !!! "
./tap-build-profile.sh
echo "Step 4 => installing TAP developer namespace in BUILD Cluster !!! "
./tap-dev-namespace.sh