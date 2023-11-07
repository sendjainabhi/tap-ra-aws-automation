#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source ../var.conf

#delete tap from build cluster
aws eks --region $aws_region update-kubeconfig --name $TAP_BUILD_CLUSTER_NAME
echo "deleting tap from build cluster"
#delete all tap packages 
tanzu package installed delete tap -n tap-install --yes


#delete tap repo 
tanzu package repository delete tanzu-tap-repository  --namespace tap-install --yes

kubectl delete secret -n tap-install --all

#uninstall tanzu essentials
cd $HOME/tanzu-cluster-essentials
./uninstall.sh --yes

../eks-csi.sh -c $TAP_BUILD_CLUSTER_NAME --remove


#delete tap from view cluster
aws eks --region $aws_region update-kubeconfig --name $TAP_VIEW_CLUSTER_NAME
echo "deleting tap from view cluster"
#delete all tap packages 
tanzu package installed delete tap -n tap-install --yes


#delete tap repo 
tanzu package repository delete tanzu-tap-repository  --namespace tap-install --yes

kubectl delete secret -n tap-install --all




#uninstall tanzu essentials
cd $HOME/tanzu-cluster-essentials
./uninstall.sh --yes

../eks-csi.sh -c $TAP_VIEW_CLUSTER_NAME --remove


#delete tap from run cluster
aws eks --region $aws_region update-kubeconfig --name $TAP_RUN_CLUSTER_NAME
echo "deleting tap from run cluster"
#delete all tap packages 
tanzu package installed delete tap -n tap-install --yes


#delete tap repo 
tanzu package repository delete tanzu-tap-repository  --namespace tap-install --yes

kubectl delete secret -n tap-install --all




#uninstall tanzu essentials
cd $HOME/tanzu-cluster-essentials
./uninstall.sh --yes

../eks-csi.sh -c $TAP_RUN_CLUSTER_NAME --remove


#delete tap from iterate cluster
aws eks --region $aws_region update-kubeconfig --name $TAP_ITERATE_CLUSTER_NAME
echo "deleting tap from iterate cluster"
#delete all tap packages 
tanzu package installed delete tap -n tap-install --yes


#delete tap repo 
tanzu package repository delete tanzu-tap-repository  --namespace tap-install --yes

kubectl delete secret -n tap-install --all

kubectl delete serviceaccount -n tap-install --all


#uninstall tanzu essentials
cd $HOME/tanzu-cluster-essentials
./uninstall.sh --yes

../eks-csi.sh -c $TAP_ITERATE_CLUSTER_NAME --remove

#sudo rm -r $HOME/tanzu-cluster-essentials/
#sudo rm -r $HOME/tanzu/

echo "deleting tanzu cli"
# you can uncomment and execute below commands to delete tanzu cli from terminal
#sudo rm -rf $HOME/tanzu/cli        # Remove previously downloaded cli files
#sudo rm /usr/local/bin/tanzu  # Remove CLI binary (executable)
#sudo rm -rf ~/.config/tanzu/       # current location # Remove config directory
#sudo rm -rf ~/.tanzu/              # old location # Remove config directory
#sudo rm -rf ~/.cache/tanzu         # remove cached catalog.yaml
#sudo rm -rf ~/Library/Application\ Support/tanzu-cli/* # Remove plug-ins

echo "tanzu cli and tap packages deleted"
