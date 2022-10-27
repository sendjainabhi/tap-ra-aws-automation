
if [[ $(echo $PWD | awk -F '/' '{print $NF}') == "tap-delete" ]]
then #move to tap-scripts dir
  cd ../
fi

source var.conf

#delete tap from build cluster
./eks-csi.sh -c tap-build --remove
aws eks --region $aws_region update-kubeconfig --name tap-build
echo "deleting tap from build cluster"
#delete all tap packages 
tanzu package installed delete tap -n tap-install --yes


#delete tap repo 
tanzu package repository delete tanzu-tap-repository  --namespace tap-install --yes

kubectl delete secret -n tap-install --all

kubectl delete ns tap-install

#uninstall tanzu essentials
cd $HOME/tanzu-cluster-essentials
./uninstall.sh --yes

#delete tap from view cluster
./eks-csi.sh -c tap-view --remove
aws eks --region $aws_region update-kubeconfig --name tap-view
echo "deleting tap from view cluster"
#delete all tap packages 
tanzu package installed delete tap -n tap-install --yes


#delete tap repo 
tanzu package repository delete tanzu-tap-repository  --namespace tap-install --yes

kubectl delete secret -n tap-install --all

kubectl delete ns tap-install

#uninstall tanzu essentials
cd $HOME/tanzu-cluster-essentials
./uninstall.sh --yes

#delete tap from run cluster
./eks-csi.sh -c tap-run --remove
aws eks --region $aws_region update-kubeconfig --name tap-run
echo "deleting tap from run cluster"
#delete all tap packages 
tanzu package installed delete tap -n tap-install --yes


#delete tap repo 
tanzu package repository delete tanzu-tap-repository  --namespace tap-install --yes

kubectl delete secret -n tap-install --all

kubectl delete ns tap-install

#uninstall tanzu essentials
cd $HOME/tanzu-cluster-essentials
./uninstall.sh --yes

#delete tap from iterate cluster
./eks-csi.sh -c tap-iterate build --remove
aws eks --region $aws_region update-kubeconfig --name tap-iterate
echo "deleting tap from iterate cluster"
#delete all tap packages 
tanzu package installed delete tap -n tap-install --yes


#delete tap repo 
tanzu package repository delete tanzu-tap-repository  --namespace tap-install --yes

kubectl delete secret -n tap-install --all

kubectl delete serviceaccount -n tap-install --all

kubectl delete ns tap-install

#uninstall tanzu essentials
cd $HOME/tanzu-cluster-essentials
./uninstall.sh --yes

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

echo "tanuz cli and tap packages deleted"