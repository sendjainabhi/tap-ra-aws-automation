#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf

chmod +x tanzu-essential-setup.sh
chmod +x tap-repo.sh
chmod +x tap-run-profile.sh
chmod +x tap-dev-namespace.sh

chmod +x var-input-validatation.sh

./var-input-validatation.sh

echo  "Log in to RUN Cluster !!! "
kubectl config set-cluster ${TAP_RUN_CLUSTER_NAME} --server=${TAP_RUN_CLUSTER_SERVER} --certificate-authority=${TAP_RUN_CLUSTER_CACERT_FILE}
kubectl config set-credentials ${TAP_RUN_CLUSTER_USER} --client-certificate=${TAP_RUN_CLUSTER_CERT_FILE} --client-key=${TAP_RUN_CLUSTER_KEY_FILE}
kubectl config set-context ${TAP_RUN_CLUSTER_USER}@${TAP_RUN_CLUSTER_NAME} --cluster=${TAP_RUN_CLUSTER_NAME} --user=${TAP_RUN_CLUSTER_USER}
kubectl config use-context ${TAP_RUN_CLUSTER_USER}@${TAP_RUN_CLUSTER_NAME}

#echo "Step 1 => installing tanzu essential in RUN cluster !!!"
#./tanzu-essential-setup.sh
echo "Step 2 => installing TAP Repo in RUN cluster !!! "
./tap-repo.sh
echo "Step 3 => installing TAP RUN Profile !!! "
./tap-run-profile.sh
echo "Step 4 => installing TAP developer namespace in RUN cluster !!! "
./tap-dev-namespace.sh