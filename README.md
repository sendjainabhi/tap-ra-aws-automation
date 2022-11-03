## Purpose

This project is designed to build a Tanzu Application Platform 1.2 multicluster instances on VCD+CSE TKGm clusters that corresponds to the [Tanzu Application Platform Reference Design](https://github.com/vmware-tanzu-labs/tanzu-validated-solutions/blob/main/src/reference-designs/tap-architecture-planning.md) . 

This is a 1-step automation with minimum inputs into config files. This scripts assume that Tanzu Cluster essentials are already present in the TKG cluster.

* **Step 1** To install TAP full profile into Tanzu K8S clusters.

Specifically, this automation will build:
- Install Tanzu Application Platform profiles such as view,run,build,iterate on Respective TKGm clusters. 
- Install Tanzu Application Platform sample demo app. 

## [Prerequisites](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.2/tap/GUID-prerequisites.html)

* Install kubectl cli.
* An account with write permissions in a Docker Registry (DockerHub, Harbor, AWS ECR, Azure ACR).
* Have a Tanzu Network account and [Accept the Tanzu EULA](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.2/tap/GUID-install-tanzu-cli.html#accept-eulas).
* Network access to the Tanzu Public Registry: https://registry.tanzu.vmware.com
* A Git repository for tap-gui software catalogs (GitHub, Gitlab, Azure DevOps).

## Prepare the Environment

### Add TAP configuration mandatory details 

Add following details into `/tap-scripts/var.conf` file to fullfill tap prerequisites. Examples and default values are given in sample below. All fields are mandatory. They can't be leave blank and must be filled before executing the `tap-index.sh` script. Refer to the sample config file below. 

```
TAP_DEV_NAMESPACE="default"
os=<terminal os as m or l.  m for Mac , l for linux/ubuntu>
INSTALL_REGISTRY_HOSTNAME="registry.tanzu.vmware.com"
INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:e00f33b92d418f49b1af79f42cb13d6765f1c8c731f4528dfff8343af042dc3e
DOCKERHUB_REGISTRY_URL=index.docker.io
TAP_VERSION=1.2.0
TAP_NAMESPACE="tap-install"
tanzu_net_reg_user=<Provide tanzu net user>
tanzu_net_reg_password=<Provide tanzu net password>
tanzu_net_api_token=<Provide tanzu net token>
registry_url=<Provide user registry url>
registry_user=<Provide user registry userid>
registry_password=<Provide user registry password>

#TAP VIEW
alv_domain=<app live view  sub domain example like :alv.ab-tap.customer0.io>
tap_view_app_domain=<view  cluster sub domain example like :view.ab-tap.customer0.io>
tap_git_catalog_url=<git catelog url example like : https://github.com/sendjainabhi/tap/blob/main/catalog-info.yaml>
TAP_VIEW_CLUSTER_NAME=tap-view
TAP_VIEW_CLUSTER_SERVER=<TAP View cluster server URL address example like : https://A.B.C.D:6443>
TAP_VIEW_CLUSTER_USER=tap-view-admin
TAP_VIEW_CLUSTER_CERT_FILE=<K8S View cluster user certificate file location>
TAP_VIEW_CLUSTER_KEY_FILE=<K8S View cluster user certificate key location>
TAP_VIEW_CLUSTER_CACERT_FILE=<K8S View cluster CA certificate file location>

#TAP RUN
tap_run_cnrs_domain=<run cluster sub domain example like : run.ab-tap.customer0.io>
TAP_RUN_CLUSTER_NAME=tap-run
TAP_RUN_CLUSTER_SERVER=<TAP Run cluster server URL address example like : https://A.B.C.D:6443>
TAP_RUN_CLUSTER_USER=tap-run-admin
TAP_RUN_CLUSTER_CERT_FILE=<K8S Run cluster user certificate file location>
TAP_RUN_CLUSTER_KEY_FILE=<K8S Run cluster user certificate key location>
TAP_RUN_CLUSTER_CACERT_FILE=<K8S Run cluster CA certificate file location>

#TAP BUILD
TAP_BUILD_CLUSTER_NAME=tap-build
TAP_BUILD_CLUSTER_SERVER=<TAP Build cluster server URL address example like : https://A.B.C.D:6443>
TAP_BUILD_CLUSTER_USER=tap-build-admin
TAP_BUILD_CLUSTER_CERT_FILE=<K8S Build cluster user certificate file location>
TAP_BUILD_CLUSTER_KEY_FILE=<K8S Build cluster user certificate key location>
TAP_BUILD_CLUSTER_CACERT_FILE=<K8S Build cluster CA certificate file location>

#TAP ITERATE
TAP_ITERATE_CLUSTER_NAME=tap-iterate
TAP_ITERATE_CLUSTER_SERVER=<TAP Iterate cluster server URL address example like : https://A.B.C.D:6443>
TAP_ITERATE_CLUSTER_USER=tap-iterate-admin
TAP_ITERATE_CLUSTER_CERT_FILE=<K8S Iterate cluster user certificate file location>
TAP_ITERATE_CLUSTER_KEY_FILE=<K8S Iterate cluster user certificate key location>
TAP_ITERATE_CLUSTER_CACERT_FILE=<K8S Iterate cluster CA certificate file location>

#tap-gui
TAP_GUI_CERT=<HTTPS FullChain cert absolute path  for tap-gui>
TAP_GUI_KEY=<HTTPS Key absolute path for tap-gui>

#tap demo app properties
TAP_APP_NAME="tap-demo"
TAP_APP_GIT_URL="https://github.com/sample-accelerators/spring-petclinic"
```

In the following lines you will find notes on how to obtain the values to fill some of the  required variables:

* tanzu_net_reg_user: Tanzu Network username. It is usually an email.
* tanzu_net_reg_password: Tanzu Network password. Special characters shall be scaped with the '\' character.
* tanzu_net_api_token: This token can be obtained in Tanzu Network by navigating to the User menu, Edit Profile, UAA API TOKEN and then clicking the button "REQUEST NEW REFRESH TOKEN".
* registry_url: If using Docker Hub, the registry URL shall be `index.docker.io`. This registry will be used to store all the builder images and the generated workload images.
* registry_user: Username of the container registry.
* registry_password: Password of the container registry. This password may be an access token issued by the registry.
* tap_git_catalog_url: GIT Url where the catalog yaml file for tap-gui is located.

## Install TAP

### Install TAP multi clusters (Run/View/Build/Iterate)

Execute the following steps to Install TAP multi clusters (Run/View/Build/Iterate)
```

#Step 1 - Add execute Permission to tap-index.sh file
chmod +x /tap-scripts/tap-index.sh

#Step 2 - Run tap-index file 
./tap-scripts/tap-index.sh


```

### Create DNS records

Pick an external ip from service output from eks view and run clusters and configure DNS wildcard records in your dns server for view and run cluster
 * **Example view cluster** - *.view.customer0.io ==> <ingress external ip/cname>
 * **Example run cluster** - *.run.customer0.io ==> <ingress external ip/cname>
 * **Example iterate cluster** - *.iter.customer0.io ==> <ingress external ip/cname>

### TAP single profile(Run/View/Build/Iterate) installation 

You can install only any single TAP profile(Run/View/Build/Iterate) as well 

* **To install View profile only , execute following step** 

```

#Step 1 - Add execute Permission to tap-view.sh file
chmod +x /tap-scripts/tap-view.sh

#Step 2 - Run tap-view.sh file 
./tap-scripts/tap-view.sh


```

* **To install Run profile only , execute following step** 

```

#Step 1 - Add execute Permission to tap-run.sh file
chmod +x /tap-scripts/tap-run.sh

#Step 2 - Run tap-run.sh file 
./tap-scripts/tap-run.sh


```

* **To install build profile only , execute following step** 

```

#Step 1 - Add execute Permission to tap-build.sh file
chmod +x /tap-scripts/tap-build.sh

#Step 2 - Run tap-build.sh file 
./tap-scripts/tap-build.sh


```


* **To install iterate profile only , execute following step** 

```

#Step 1 - Add execute Permission to tap-iterate.sh file
chmod +x /tap-scripts/tap-iterate.sh

#Step 2 - Run tap-iterate.sh file 
./tap-scripts/tap-iterate.sh


```

### TAP scripts for specific tasks

If you got stuck in any specific stage and need to resume installation, you can use the following scripts. Log in to respective EKS cluster before running these scripts.

* **Install tanzu cli** - Run `./tap-scripts/tanzu-cli-setup.sh`

* **Install tanzu essentials** - Run `./tap-scripts/tanzu-essential-setup.sh`. This step is commented in the different tap-<profile>.sh scripts, as this automation project is for TKGm K8S clusters delivered by VCD+CSE. Tanzu Essentials shall be already installed.

* **Setup TAP repository** - Run `./tap-scripts/tanzu-repo.sh`  

* **Install TAP run profile packages** - Run `./tap-scripts/tanzu-run-profile.sh`  

* **Install TAP build profile packages** - Run `./tap-scripts/tanzu-build-profile.sh`

* **Install TAP view profile packages** - Run `./tap-scripts/tanzu-view-profile.sh`

When creating TKGm clusters with VCD+CSE, you can obtain the kubeconfig files as ' `kubeconfig-<clusterName>.txt` files. To extract the user key and certificate and the CA certificate, you can make use of the `helpers/extract-kubeconfig-certs.sh` script.

* **Extract Keys and Certificate files from Kubeconfig** - Copy `kubeconfig-<clusterName>.txt` files in the helpers folder and run `./tap-scripts/helpers/extract-kubeconfig-certs.sh <Cluster Name Prefix>`. e.g. if the kubeconfigfiles are a named kubeconfig-tap-[view|run|iterate|build].txt, the <Cluster Name Prefix> parameter should be `-tap-`.

## Clean up

### Delete TAP instances from all eks clusters 

Please follow below steps 
```

1. Run chmod +x /tap-scripts/tap-delete/tap-delete.sh
2. Run ./tap-scripts/tap-delete/tap-delete.sh
 
# Delete single tap cluster instance 
1. Log in to eks clusters(view/run/build/iterate) using kubeconfig where you want to delete tap.
2. Run chmod +x /tap-scripts/tap-delete/tap-delete-single-cluster.sh
3. Run ./tap-scripts/tap-delete/tap-delete-single-cluster.sh

```