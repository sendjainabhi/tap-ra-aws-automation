

#!/bin/bash
source var.conf

#export TAP_NAMESPACE="tap-install"
export TAP_REGISTRY_SERVER=$registry_url
export TAP_REGISTRY_USER=$registry_user
export TAP_REGISTRY_PASSWORD=$registry_password
export TAP_CNRS_DOMAIN=$tap_run_cnrs_domain


cat <<EOF | tee tap-values-iterate.yaml

profile: iterate

ceip_policy_disclosed: true

buildservice:
  kp_default_repository: "${TAP_REGISTRY_SERVER}/build-service"
  kp_default_repository_username: "${TAP_REGISTRY_USER}"
  kp_default_repository_password: "${TAP_REGISTRY_PASSWORD}"
  tanzunet_username: "${INSTALL_REGISTRY_USERNAME}"
  tanzunet_password: "${INSTALL_REGISTRY_PASSWORD}"
  descriptor_name: "full"
  enable_automatic_dependency_updates: true

supply_chain: basic
ootb_supply_chain_basic:
  registry:
    server: "${TAP_REGISTRY_SERVER}"
    repository: "supply-chain"
  gitops:
    ssh_secret: ""

metadata_store:
  app_service_type: LoadBalancer

image_policy_webhook:
  allow_unmatched_tags: true

contour:
  envoy:
    service:
      type: LoadBalancer

cnrs:
  domain_name: "${tap_iterate_cnrs_domain}"

EOF

tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file tap-values-iterate.yaml -n "${TAP_NAMESPACE}"
tanzu package installed get tap -n "${TAP_NAMESPACE}"

# check all build cluster package installed succesfully
tanzu package installed list -A

# check ingress external ip
kubectl get svc -n tanzu-system-ingress

echo "pick external ip from service output  and configure DNS wild card(*) into your DNS server like aws route 53 etc"
echo "example - *.iter.customer0.io ==> <ingress external ip/cname>"