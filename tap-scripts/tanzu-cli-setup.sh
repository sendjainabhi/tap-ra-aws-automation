#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf


export TANZU_NET_API_TOKEN=$tanzu_net_api_token
export INSTALL_REGISTRY_USERNAME=$tanzu_net_reg_user
export INSTALL_REGISTRY_PASSWORD=$tanzu_net_reg_password



export token=$(curl -X POST https://network.pivotal.io/api/v2/authentication/access_tokens -d '{"refresh_token":"'${TANZU_NET_API_TOKEN}'"}')
access_token=$(echo ${token} | jq -r .access_token)

curl -i -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer ${access_token}" -X GET https://network.pivotal.io/api/v2/authentication

echo "Enter your terminal OS as (l or m)- l as linux , m as mac in var config file"

var="m"
filename=""

if [ "$os" == "$var" ]; then
    echo "OS = mac"

# install tanzu cli v(0.25.4) and plug-ins (mac)
#url linux-  tanzu cli -  https://network.tanzu.vmware.com/api/v2/products/tanzu-application-platform/releases/1239018/product_files/1404618/download

#url mac- tanzu cli - https://network.tanzu.vmware.com/api/v2/products/tanzu-application-platform/releases/1239018/product_files/1404617/download


#file name - mac= tanzu-framework-darwin-amd64.tar , linux= tanzu-framework-linux-amd64.tar



brew update
brew install vmware-tanzu/tanzu/tanzu-cli

# install yq package 
 wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_darwin_amd64
 sudo chmod a+x /usr/local/bin/yq
yq --version
   
else
    echo "OS = Linux/ubuntu"

# install tanzu cli v(0.25.4) and plug-ins (linux)
sudo mkdir -p /etc/apt/keyrings/
sudo apt-get update
sudo apt-get install -y ca-certificates curl gpg
curl -fsSL https://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub | sudo gpg --dearmor -o /etc/apt/keyrings/tanzu-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/tanzu-archive-keyring.gpg] https://storage.googleapis.com/tanzu-cli-os-packages/apt tanzu-cli-jessie main" | sudo tee /etc/apt/sources.list.d/tanzu.list
sudo apt-get update
sudo apt-get install -y tanzu-cli

# install yq package 
 wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
 sudo chmod a+x /usr/local/bin/yq
yq --version

fi


#tanzu init
tanzu version

# tanzu plug-ins
#tanzu plugin clean
tanzu plugin install --group vmware-tap/default:v1.6.1
#tanzu plugin sync
tanzu plugin list


cd $HOME
