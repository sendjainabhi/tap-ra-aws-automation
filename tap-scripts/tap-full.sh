#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause

set -e
source var.conf

chmod +x tanzu-essential-setup.sh
chmod +x tap-repo.sh
chmod +x tap-full-profile.sh
chmod +x tap-dev-namespace.sh
chmod +x eks-csi.sh

chmod +x var-input-validatation.sh

./var-input-validatation.sh

echo  "Full profile Cluster - Login and check AWS EKS CSI Driver"
./eks-csi.sh -c $TAP_FULL_CLUSTER_NAME
echo "Step 1 => installing tanzu cli !!!"
./tanzu-cli-setup.sh
echo "Step 2 => installing tanzu essential in full cluster !!!"
./tanzu-essential-setup.sh
echo "Step 2 => installing TAP Repo in full cluster !!! "
./tap-repo.sh
echo "Step 4 => installing TAP full Profile !!! "
./tap-full-profile.sh
echo "Step 4 => installing TAP developer namespace in full cluster !!! "
./tap-dev-namespace.sh