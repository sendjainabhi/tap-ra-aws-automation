## Purpose

This project is designed to build a Tanzu Application Platform 1.6.x multicluster instances on AWS EKS that corresponds to the [Tanzu Application Platform Reference Design](https://github.com/vmware-tanzu-labs/tanzu-validated-solutions/blob/main/src/reference-designs/tap-architecture-planning.md) . 

This is 2 steps automation with minimum inputs into config files. 

* **Step 1** to create all aws resources for tap like VPC , 4 eks clusters and associated security and Iam group , node etc
* **Step 2** to install tap profiles into eks clusters.

Specifically, this automation will build:
- an aws VPC (internet facing)
- 4 EKS clusters named as tap-view , tap-run , tap-build,tap-iterate and associated security IAM roles and groups and nodes into aws. 
- Install Tanzu Application Platform profiles such as view,run,build,iterate on Respective eks clusters. 
- Install Tanzu Application Platform sample demo app. 

## AWS resources matrix 

 **Resource Name** | **Size/Number**  
 -----|-----
 VPC | 1
 Subnets | 2 private , 2 public
 VPC cidr | 10.0.0.0/16
 EKS clusters | 4
 Nodes per eks cluster | Nodes : 3, Node Size : t2.xlarge , Storage : 100GB disk size
## Prerequisite 

Following cli must be setup into jumbbox or execution machine/terminal. 
   * terraform cli 
   * aws cli 


## Prepare the Environment

First, be sure that your AWS access credentials are available within your environment.

### Set aws env variables.
 
```bash
export AWS_ACCESS_KEY_ID=<your AWS access key>
export AWS_SECRET_ACCESS_KEY=<your AWS secret access key>
export AWS_REGION=us-east-1  # ensure the region is set correctly. this must agree with what you set in the tf files below.
```
**Note** - Even if you are only running TAP scripts on existing eks clusters , please set above `aws` environment variables.

### Prepare Terraform

* Initialize Terraform by executing `terraform init`
* Set required variables in `terraform.tfvars`
  * `availability_zones_count` Should be set to number of subnets(private/public) you want to create within vpc.
  * `vpc_cidr` Should be set cidr for vpc. 
  * `aws_region` Should be set to your AWS region
  * `subnet_cidr_bits` Should be set cidr bits for vpc.

* Execute Terraform apply by exeuting `terraform apply`

### Add TAP configuration mandatory details 

Add following details into `/tap-scripts/var.conf` file to fullfill tap prerequisite. Examples and default values given in below sample. All fields are mandatory and can't be leave blank and must be filled before executing the `tap-index.sh` . Please refer below sample config file. 
```
TAP_DEV_NAMESPACE="default"
os=<terminal os as m or l.  m for Mac , l for linux/ubuntu>
INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:54e516b5d088198558d23cababb3f907cd8073892cacfb2496bb9d66886efe15
INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
TAP_VERSION=1.6.1
K8_Version=1.26


DOCKERHUB_REGISTRY_URL=index.docker.io
TAP_NAMESPACE="tap-install"
tanzu_net_reg_user=<Provide tanzu net user>
tanzu_net_reg_password=<Provide tanzu net password>
tanzu_net_api_token=<Provide tanzu net token>
aws_region=<aws region where tap eks clusters created>
registry_url=<Provide user registry url>
registry_user=<Provide user registry userid>
registry_password=<Provide user registry password>
TAP_GITHUB_TOKEN=< git hub token>

#tap clusters dns

tap_run_domain=<run cluster sub domain example like : run.ab-tap.customer0.io >
tap_view_domain=<view  cluster sub domain example like :view.ab-tap.customer0.io>
tap_iterate_domain=<iterate cluster sub domain example like : iter.ab-tap.customer0.io>
tap_full_domain=<full cluster sub domain example like : full.ab-tap.customer0.io>


TAP_RUN_CLUSTER_NAME="tap-run"
TAP_BUILD_CLUSTER_NAME="tap-build"
TAP_VIEW_CLUSTER_NAME="tap-view"
TAP_ITERATE_CLUSTER_NAME="tap-iterate"
TAP_FULL_CLUSTER_NAME="tap-full"
tap_git_catalog_url=<git catelog url example like : https://github.com/sendjainabhi/tap/blob/main/catalog-info.yaml>

#tanzu essential 
tanzu_ess_filename_m=tanzu-cluster-essentials-darwin-amd64-1.6.0.tgz
tanzu_ess_filename_l=tanzu-cluster-essentials-linux-amd64-1.6.0.tgz
tanzu_ess_url_m=https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1321952/product_files/1526700/download
tanzu_ess_url_l=https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1321952/product_files/1526701/download


#tap demo app properties
TAP_APP_NAME="spring-music"
TAP_APP_GIT_URL="https://github.com/PeterEltgroth/spring-music"



```
## Install TAP
### Build EKS clusters 
Execute following steps to build aws resources for TAP. 

*  Execute `terraform plan ` from /terraform directory and review all aws resources.

* Execute `terraform apply` to build aws resources.

### Install TAP multi clusters (Run/View/Build/Iterate)

Execute following steps to Install TAP multi clusters (Run/View/Build/Iterate)
```

#Step 1 - Execute Permission to tap-index.sh file
chmod +x /tap-scripts/tap-index.sh

#Step 2 - Execute tap-index file 
./tap-scripts/tap-index.sh


```
**Note** - 

 Pick an external ip from service output from eks view and run clusters and configure DNS wildcard records in your dns server for view and run cluster
 * **Example view cluster** - *.view.customer0.io ==> <ingress external ip/cname>
 * **Example run cluster** - *.run.customer0.io ==> <ingress external ip/cname>
  * **Example iterate cluster** - *.iter.customer0.io ==> <ingress external ip/cname>
### TAP single profile(Run/View/Build/Iterate) installation 

You can install only any single TAP profile(Run/View/Build/Iterate) as well 

* **To install View profile only , execute following step** 

```

#Step 1 - Execute Permission to tap-view.sh file
chmod +x /tap-scripts/tap-view.sh

#Step 2 - Execute tap-view.sh file 
./tap-scripts/tap-view.sh


```

* **To install Run profile only , execute following step** 

```

#Step 1 - Execute Permission to tap-run.sh file
chmod +x /tap-scripts/tap-run.sh

#Step 2 - Execute tap-run.sh file 
./tap-scripts/tap-run.sh


```

> **NOTE:** This TAP Version (1.3.0) has a bug in the policy-controller package that prevents it to start successfully and reconcile. It has been excluded in the configuration. Namespaces manually labeled to undergo signature verification will not be able to verify the signature of an image before it is let into the cluster

* **To install build profile only , execute following step** 

```

#Step 1 - Execute Permission to tap-build.sh file
chmod +x /tap-scripts/tap-build.sh

#Step 2 - Execute tap-build.sh file 
./tap-scripts/tap-build.sh


```


* **To install iterate profile only , execute following step** 

```

#Step 1 - Execute Permission to tap-iterate.sh file
chmod +x /tap-scripts/tap-iterate.sh

#Step 2 - Execute tap-iterate.sh file 
./tap-scripts/tap-iterate.sh


```

* **To install full profile only , execute following step** 

```

#Step 1 - Execute Permission to tap-full.sh file
chmod +x /tap-scripts/tap-full.sh

#Step 2 - Execute tap-full.sh file 
./tap-scripts/tap-full.sh


```
### TAP scripts for specific tasks

If you got stuck in any specific stage and need to resume installation , you can use following scripts.Please login to respective EKS cluster before executing these scripts.

* **Install tanzu cli** - execute `./tap-scripts/tanzu-cli-setup.sh`

* **Install tanzu essentials** - execute `./tap-scripts/tanzu-essential-setup.sh`  

* **Setup TAP repository** - execute `./tap-scripts/tanzu-repo.sh`  

* **Install TAP run profile packages** - execute `./tap-scripts/tanzu-run-profile.sh`  

* **Install TAP build profile packages** - execute `./tap-scripts/tanzu-build-profile.sh`

* **Install TAP view profile packages** - execute `./tap-scripts/tanzu-view-profile.sh`

## Clean up

### Delete TAP instances from all eks clusters 

Please follow below steps 
```

1. execute chmod +x /tap-scripts/tap-delete/tap-delete.sh
2. execute ./tap-scripts/tap-delete/tap-delete.sh
 
# Delete single tap cluster instance 
1. Login to eks clusters(view/run/build/iterate) using kubeconfig where you want to delete tap.
2. execute chmod +x /tap-scripts/tap-delete/tap-delete-single-cluster.sh
3. execute ./tap-scripts/tap-delete/tap-delete-single-cluster.sh

```
### Delete EKS clusters instances from eks cluster 
Run `terraform destroy` to destroy to delete all aws resources created by terraform. In some instances it is possible that `terraform destroy` will not be able to clean up after a failed Tanzu install. Especially in situations where the management cluster only comes partially up for whatever reason. In this circumstance you can recursively delete the VPCs that failed to get destroyed and use the tags "CreatedBy: Arcas" to find anything that was generated by this terraform.

### Troubleshooting 
 * if `terraform destroy` command not able to delete aws vpc resources then you can manually delete aws load balancer created by tap under tap vpc and run `terraform destroy` command again. 

### Known issues 
* View cluster `tap-gui` UI is not able to fetch apps run time resources due to timed out issue , due to cluster communications timed out error.  

Error log 
```
Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36\""}
{"ts":"2022-11-15T20:46:45.905Z","level":"info","meta":{"type":"incomingRequest","service":"backstage"},"msg":"::ffff:10.0.3.196 - - [15/Nov/2022:20:46:45 +0000] \"POST /api/kubernetes/services/spring-music HTTP/1.1\" - - \"-\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36\""}
{"ts":"2022-11-15T20:47:15.189Z","level":"error","meta":{"type":"plugin","plugin":"kubernetes","service":"backstage"},"err":"action=retrieveObjectsByServiceId service=spring-music, error=Error: connect ETIMEDOUT 10.0.1.73:443"}
```


 