#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause

set -e
source var.conf

chmod +x tanzu-essential-setup.sh
chmod +x tap-repo.sh
chmod +x tap-run-profile.sh
chmod +x tap-dev-namespace.sh
chmod +x eks-csi.sh

chmod +x var-input-validatation.sh

./var-input-validatation.sh

echo  "RUN Cluster - Login and install AWS EKS CSI Driver"
./eks-csi.sh -c $TAP_RUN_CLUSTER_NAME

echo "Step 1 => installing tanzu essential in RUN cluster !!!"
./tanzu-essential-setup.sh
echo "Step 2 => installing TAP Repo in RUN cluster !!! "
./tap-repo.sh
echo "Step 3 => installing TAP RUN Profile !!! "
./tap-run-profile.sh
echo "Step 4 => installing TAP developer namespace in RUN cluster !!! "
./tap-dev-namespace.sh