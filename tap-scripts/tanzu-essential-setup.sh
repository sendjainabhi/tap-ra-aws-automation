
#!/bin/bash
source var.conf

export INSTALL_BUNDLE=$INSTALL_BUNDLE
export INSTALL_REGISTRY_HOSTNAME=$INSTALL_REGISTRY_HOSTNAME
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

# install tanzu cluster essentials

#mac - https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1180593/product_files/1330472/download
#linux -https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1180593/product_files/1330470/download
#file name - mac = tanzu-cluster-essentials-darwin-amd64-1.3.0.tgz , linux = tanzu-cluster-essentials-linux-amd64-1.3.0.tgz

filename=tanzu-cluster-essentials-darwin-amd64-1.3.0.tgz

if [[ -f "$HOME/tanzu-cluster-essentials/$filename" ]]; then
    echo "$HOME/tanzu-cluster-essentials/$filename exists, skipping download"
else
    tanzuessnurl=https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1180593/product_files/1330472/download
    mkdir $HOME/tanzu-cluster-essentials
    wget $tanzuessnurl --header="Authorization: Bearer ${access_token}" -O $HOME/tanzu-cluster-essentials/$filename
    tar -xvf $HOME/tanzu-cluster-essentials/$filename -C $HOME/tanzu-cluster-essentials

    sudo cp $HOME/tanzu-cluster-essentials/kapp /usr/local/bin/kapp
    sudo cp $HOME/tanzu-cluster-essentials/imgpkg /usr/local/bin/imgpkg
fi
cd $HOME/tanzu-cluster-essentials
./install.sh --yes

else
    echo "OS = Linux/ubuntu"

#mac - https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1180593/product_files/1330472/download
#linux -https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1180593/product_files/1330470/download
#file name - mac = tanzu-cluster-essentials-darwin-amd64-1.3.0.tgz , linux = tanzu-cluster-essentials-linux-amd64-1.3.0.tgz

filename=tanzu-cluster-essentials-linux-amd64-1.3.0.tgz
tanzuessnurl=https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1180593/product_files/1330470/download
mkdir $HOME/tanzu-cluster-essentials
wget $tanzuessnurl --header="Authorization: Bearer ${access_token}" -O $HOME/tanzu-cluster-essentials/$filename
tar -xvf $HOME/tanzu-cluster-essentials/$filename -C $HOME/tanzu-cluster-essentials

cd $HOME/tanzu-cluster-essentials
./install.sh --yes

sudo cp $HOME/tanzu-cluster-essentials/kapp /usr/local/bin/kapp
sudo cp $HOME/tanzu-cluster-essentials/imgpkg /usr/local/bin/imgpkg

fi

cd $HOME

# install DEMO-MAGIC for app demo
#wget https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh
#sudo mv demo-magic.sh /usr/local/bin/demo-magic.sh
#chmod +x /usr/local/bin/demo-magic.sh

#sudo apt install pv #required for demo-magic
