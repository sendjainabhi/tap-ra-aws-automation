# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf

if [ -z "$tanzu_net_reg_user" ] || [ -z "$tanzu_net_reg_password" ] || [ -z "$tanzu_net_api_token" ] || [ -z "$os" ] 
then 
    echo 'Error : Any of tanzu_net_reg_user,tanzu_net_reg_password,tanzu_net_api_token or os fields cannot be leave empty into var.conf, please add appropriate value!' 
    exit 0 
fi 

if [ -z "$registry_url" ] || [ -z "$registry_user" ] ||  [ -z "$registry_password" ] 
then 
    echo 'Error : Any of registry_url,registry_user or registry_password fields cannot be leave empty into var.conf, please add appropriate value!' 
    exit 0 
fi 

if [ -z "$tap_git_catalog_url" ] || [ -z "$alv_domain" ] || [ -z "$tap_view_app_domain" ] || [ -z "$tap_run_cnrs_domain" ]
then 
    echo 'Error : Any of tap_git_catalog_url, alv_domain, tap_view_app_domain or tap_run_cnrs_domain fields cannot be leave empty into var.conf, please add appropriate value!' 
    exit 0 
fi 

if [ -z "$TAP_GUI_CERT" ] || [ -z "$TAP_GUI_KEY" ]
then 
    echo 'Error : Any of TAP_GUI_CERT or TAP_GUI_KEY fields cannot be leave empty into var.conf, please add appropriate value!' 
    exit 0 
fi 

if [ -z "$TAP_VIEW_CLUSTER_SERVER" ] || [ -z "$TAP_VIEW_CLUSTER_CERT_FILE" ] || [ -z "$TAP_VIEW_CLUSTER_KEY_FILE" ] || [ -z "$TAP_VIEW_CLUSTER_CACERT_FILE" ]
then 
    echo 'Error : Any of TAP_VIEW_CLUSTER_SERVER, TAP_VIEW_CLUSTER_CERT_FILE, TAP_VIEW_CLUSTER_KEY_FILE or TAP_VIEW_CLUSTER_CACERT_FILE fields cannot be leave empty into var.conf, please add appropriate value!' 
    exit 0 
fi 

if [ -z "$TAP_RUN_CLUSTER_SERVER" ] || [ -z "$TAP_RUN_CLUSTER_CERT_FILE" ] || [ -z "$TAP_RUN_CLUSTER_KEY_FILE" ] || [ -z "$TAP_RUN_CLUSTER_CACERT_FILE" ]
then 
    echo 'Error : Any of TAP_RUN_CLUSTER_SERVER, TAP_RUN_CLUSTER_CERT_FILE, TAP_RUN_CLUSTER_KEY_FILE or TAP_RUN_CLUSTER_CACERT_FILE fields cannot be leave empty into var.conf, please add appropriate value!' 
    exit 0 
fi 

if [ -z "$TAP_BUILD_CLUSTER_SERVER" ] || [ -z "$TAP_BUILD_CLUSTER_CERT_FILE" ] || [ -z "$TAP_BUILD_CLUSTER_KEY_FILE" ] || [ -z "$TAP_BUILD_CLUSTER_CACERT_FILE" ]
then 
    echo 'Error : Any of TAP_BUILD_CLUSTER_SERVER, TAP_BUILD_CLUSTER_CERT_FILE, TAP_BUILD_CLUSTER_KEY_FILE or TAP_BUILD_CLUSTER_CACERT_FILE fields cannot be leave empty into var.conf, please add appropriate value!' 
    exit 0 
fi 

if [ -z "$TAP_ITERATE_CLUSTER_SERVER" ] || [ -z "$TAP_ITERATE_CLUSTER_CERT_FILE" ] || [ -z "$TAP_ITERATE_CLUSTER_KEY_FILE" ] || [ -z "$TAP_ITERATE_CLUSTER_CACERT_FILE" ]
then 
    echo 'Error : Any of TAP_ITERATE_CLUSTER_SERVER, TAP_ITERATE_CLUSTER_CERT_FILE, TAP_ITERATE_CLUSTER_KEY_FILE or TAP_ITERATE_CLUSTER_CACERT_FILE fields cannot be leave empty into var.conf, please add appropriate value!' 
    exit 0 
fi 
