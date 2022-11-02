#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf

chmod +x tanzu-essential-setup.sh
chmod +x tap-repo.sh
chmod +x tap-iterate-profile.sh
chmod +x tap-dev-namespace.sh

chmod +x var-input-validatation.sh

./var-input-validatation.sh

echo  "Login to ITERATE Cluster !!! "
kubectl config set-cluster ${TAP_ITERATE_CLUSTER_NAME} --server=${TAP_ITERATE_CLUSTER_SERVER} --certificate-authority=${TAP_ITERATE_CLUSTER_CACERT_FILE}
kubectl config set-credentials ${TAP_ITERATE_CLUSTER_USER} --client-certificate=${TAP_ITERATE_CLUSTER_CERT_FILE} --client-key=${TAP_ITERATE_CLUSTER_KEY_FILE}
kubectl config set-context ${TAP_ITERATE_CLUSTER_USER}@${TAP_ITERATE_CLUSTER_NAME} --cluster=${TAP_ITERATE_CLUSTER_NAME} --user=${TAP_ITERATE_CLUSTER_USER}
kubectl config use-context ${TAP_ITERATE_CLUSTER_USER}@${TAP_ITERATE_CLUSTER_NAME}

#echo "Step 1 => installing tanzu essential in iterate cluster !!!"
#./tanzu-essential-setup.sh
echo "Step 2 => installing TAP Repo in iterate cluster !!! "
./tap-repo.sh
echo "Step 3 => installing TAP iterate Profile !!! "
./tap-iterate-profile.sh
echo "Step 4 => installing TAP developer namespace in iterate cluster !!! "
./tap-dev-namespace.sh