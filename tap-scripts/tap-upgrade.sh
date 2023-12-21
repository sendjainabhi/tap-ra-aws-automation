

export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export TAP_VERSION=1.7.2
export TAP_NAMESPACE="tap-install"


#add tanzu repo upgraded version
tanzu package repository add tanzu-tap-repository \
  --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:$TAP_VERSION \
  --namespace "${TAP_NAMESPACE}"

#update tanzu packages 
tanzu package installed update tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file tap-values-iterate.yaml -n "${TAP_NAMESPACE}"

#verify tap upgrade packages 
tanzu package installed list --namespace tap-install
