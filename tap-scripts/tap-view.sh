#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf

chmod +x tanzu-essential-setup.sh
chmod +x tap-repo.sh
chmod +x tap-view-profile.sh
chmod +x tap-dev-namespace.sh

chmod +x var-input-validatation.sh

./var-input-validatation.sh

echo  "Log in to VIEW Cluster !!! "
kubectl config set-cluster ${TAP_VIEW_CLUSTER_NAME} --server=${TAP_VIEW_CLUSTER_SERVER} --certificate-authority=${TAP_VIEW_CLUSTER_CACERT_FILE}
kubectl config set-credentials ${TAP_VIEW_CLUSTER_USER} --client-certificate=${TAP_VIEW_CLUSTER_CERT_FILE} --client-key=${TAP_VIEW_CLUSTER_KEY_FILE}
kubectl config set-context ${TAP_VIEW_CLUSTER_USER}@${TAP_VIEW_CLUSTER_NAME} --cluster=${TAP_VIEW_CLUSTER_NAME} --user=${TAP_VIEW_CLUSTER_USER}
kubectl config use-context ${TAP_VIEW_CLUSTER_USER}@${TAP_VIEW_CLUSTER_NAME}

#echo "Step 1 => installing tanzu cli and tanzu essential in VIEW cluster !!!"
#./tanzu-essential-setup.sh
echo "Step 2 => installing TAP Repo in VIEW cluster !!! "
./tap-repo.sh
echo "Step 3 => installing TAP VIEW  Profile !!! "
./tap-view-profile.sh
echo "Step 4 => installing TAP developer namespace in VIEW cluster !!! "
./tap-dev-namespace.sh