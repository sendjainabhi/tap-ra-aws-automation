#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause

source var.conf

export TAP_REGISTRY_SERVER=$registry_url
export TAP_REGISTRY_USER=$registry_user
export TAP_REGISTRY_PASSWORD=$registry_password
export TAP_CNRS_DOMAIN=$tap_run_cnrs_domain

cat <<EOF | tee tap-values-run.yaml
profile: run
ceip_policy_disclosed: true
supply_chain: basic

contour:
  envoy:
    service:
      type: LoadBalancer

cnrs:
  domain_name: "${tap_run_cnrs_domain}"

appliveview_connector:
  backend:
    sslDisabled: "true"
    host: appliveview.$alv_domain

EOF

tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file tap-values-run.yaml -n "${TAP_NAMESPACE}"
tanzu package installed get tap -n "${TAP_NAMESPACE}"

# check all build cluster package installed succesfully
tanzu package installed list -A

# check ingress external ip
kubectl get svc -n tanzu-system-ingress

echo "pick external ip from service output  and configure DNS wild card(*) into your DNS server like aws route 53 etc"
echo "example - *.run.customer0.io ==> <ingress external ip/cname>"