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

# install tanzu cli v(0.25) and plug-ins (mac)
#url linux-  tanzu cli -  https://network.pivotal.io/api/v2/products/tanzu-application-platform/releases/1182301/product_files/1310085/download

#url mac- tanzu cli - https://network.pivotal.io/api/v2/products/tanzu-application-platform/releases/1182301/product_files/1310083/download



#file name - mac= tanzu-framework-darwin-amd64.tar , linux= tanzu-framework-linux-amd64.tar


tanzucliurl=https://network.pivotal.io/api/v2/products/tanzu-application-platform/releases/1182301/product_files/1310083/download
tanzuclifilename=tanzu-framework-darwin-amd64.tar

mkdir $HOME/tanzu
cd $HOME/tanzu
wget $tanzucliurl --header="Authorization: Bearer ${access_token}" -O $HOME/tanzu/$tanzuclifilename
tar -xvf $HOME/tanzu/$tanzuclifilename -C $HOME/tanzu

export VERSION=v0.25.0
install $HOME/tanzu/cli/core/$VERSION/tanzu-core-darwin_amd64 /usr/local/bin/tanzu


# install yq package 
 wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_darwin_amd64
 sudo chmod a+x /usr/local/bin/yq
yq --version
   
else
    echo "OS = Linux/ubuntu"

# install tanzu cli v(0.25) and plug-ins (linux)
#url linux-  tanzu cli -  https://network.pivotal.io/api/v2/products/tanzu-application-platform/releases/1182301/product_files/1310085/download
#url mac- tanzu cli - https://network.pivotal.io/api/v2/products/tanzu-application-platform/releases/1182301/product_files/1310083/download

#file name - mac= tanzu-framework-darwin-amd64.tar , linux= tanzu-framework-linux-amd64.tar

tanzucliurl=https://network.pivotal.io/api/v2/products/tanzu-application-platform/releases/1182301/product_files/1310085/download
tanzuclifilename=tanzu-framework-linux-amd64.tar


mkdir $HOME/tanzu
cd $HOME/tanzu
wget $tanzucliurl --header="Authorization: Bearer ${access_token}" -O $HOME/tanzu/$tanzuclifilename
tar -xvf $HOME/tanzu/$tanzuclifilename -C $HOME/tanzu

export VERSION=v0.25.0
 install $HOME/tanzu/cli/core/$VERSION/tanzu-core-linux_amd64 /usr/local/bin/tanzu

# install yq package 
 wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
 sudo chmod a+x /usr/local/bin/yq
yq --version

fi

export TANZU_CLI_NO_INIT=true
#tanzu init
tanzu version

# tanzu plug-ins
#tanzu plugin clean
tanzu plugin install --local cli all
#tanzu plugin sync
tanzu plugin list


cd $HOME
