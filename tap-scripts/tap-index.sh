#!/bin/bash
source var.conf
source lib/check-tools.sh

chmod +x var-input-validatation.sh
chmod +x tanzu-cli-setup.sh
chmod +x tap-cluster.sh
chmod +x tap-demo-app-deploy.sh


./var-input-validatation.sh
echo "Step 1 => Installing tanzu cli !!!"
./tanzu-cli-setup.sh
check_all_tools
echo "Step 2 => Setup TAP View Cluster"
./tap-cluster.sh -c tap-view 
echo "Step 3 => Setup TAP Run Cluster"
./tap-cluster.sh -c tap-run
echo "Step 4 => Setup TAP Build Cluster"
./tap-cluster.sh -c tap-build
echo "Step 4 => Setup TAP Build Cluster"
./tap-cluster.sh -c tap-iterate

echo "pick an external ip from service output and configure DNS wildcard records in your dns server for view and run cluster"
echo "example view cluster - *.view.customer0.io ==> <ingress external ip/cname>"
echo "example run cluster - *.run.customer0.io ==> <ingress external ip/cname> " 
echo "example iterate cluster - *.iter.customer0.io ==> <ingress external ip/cname> " 

echo "Step 5 => Deploy sample app"
./tap-demo-app-deploy.sh