# Tanzu Application Platform 1.3 Reference Architecture Installation Automation

## Purpose

This project is designed to build a Tanzu Application Platform 1.3 multicluster instances on AWS EKS that corresponds to the [Tanzu Application Platform Reference Design](https://github.com/vmware-tanzu-labs/tanzu-validated-solutions/blob/main/src/reference-designs/tap-architecture-planning.md) .

This is 2 steps automation with minimum inputs into config files.

* **Step 1** to create all aws resources for tap like VPC , 4 eks clusters and associated security and IAM group , node etc
* **Step 2** to install tap profiles into eks clusters.

Specifically, this automation will build:

* a AWS VPC (internet facing)
* 4 EKS clusters named `tap-view`, `tap-run`, `tap-build` and `tap-iterate`, and the associated security IAM roles and groups and nodes in AWS.
* Install Tanzu Application Platform profiles such as view, run, build, and iterate on the respective eks clusters.
* Install Tanzu Application Platform sample demo app.

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

* [terraform cli](https://www.terraform.io/downloads.html)
* [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [eksctl cli](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)

## Prepare the Environment

First, be sure that your AWS access credentials are available within your environment.

### Set aws env variables

```bash
export AWS_ACCESS_KEY_ID=<your AWS access key>
export AWS_SECRET_ACCESS_KEY=<your AWS secret access key>
export AWS_REGION=us-east-1  # ensure the region is set correctly. this must agree with what you set in the tf files below.
```

### Prepare Terraform

* `cd terraform`
* Initialize Terraform by executing `terraform init`
* Set required variables in `terraform.tfvars`
  * `availability_zones_count`: Number of subnets(private/public) to create in vpc
  * `vpc_cidr`: CIDR for vpc
  * `aws_region`: AWS region
  * `subnet_cidr_bits`: CIDR bits for vpc

* Execute Terraform apply by exeuting `terraform apply`

### Add TAP configuration mandatory details

Add following details into `/tap-scripts/var.conf` file to fullfill tap prerequisite. Examples and default values given in below sample. All fields are mandatory and can't be leave blank and must be filled before executing the `tap-index.sh` . Please refer below sample config file.

```bash
TAP_DEV_NAMESPACE="default"
os=<terminal os as m or l.  m for Mac , l for linux/ubuntu>
## Registry from which installation artifacts are retrieved
INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:54bf611711923dccd7c7f10603c846782b90644d48f1cb570b43a082d18e23b9
DOCKERHUB_REGISTRY_URL=index.docker.io
TAP_VERSION=1.3.0
TAP_NAMESPACE="tap-install"
tanzu_net_reg_user=<Provide tanzu net user>
tanzu_net_reg_password=<Provide tanzu net password>
tanzu_net_api_token=<Provide tanzu net token>
aws_region=<aws region where tap eks clusters created>
registry_url=<Provide user registry url>
registry_user=<Provide user registry userid>
registry_password=<Provide user registry password>
tap_run_cnrs_domain=<run cluster sub domain example like : run.ab-tap.customer0.io >
alv_domain=<app live view  sub domain example like :alv.ab-tap.customer0.io >
TAP_RUN_CLUSTER_NAME="tap-run"
TAP_GITHUB_TOKEN=< git hub token>
tap_view_app_domain=<view  cluster sub domain example like :view.ab-tap.customer0.io>
tap_git_catalog_url=<git catelog url example like : https://github.com/sendjainabhi/tap/blob/main/catalog-info.yaml>

#tap demo app properties
TAP_APP_NAME="tap-demo"
TAP_APP_GIT_URL="https://github.com/sample-accelerators/spring-petclinic"

```

## Install TAP

### Build EKS clusters

Execute following steps to build aws resources for TAP.

* Execute `terraform plan` from /terraform directory and review all aws resources.

* Execute `terraform apply` to build aws resources.

### Install TAP multi clusters (Run/View/Build/Iterate)

Execute following steps to Install TAP multi clusters (Run/View/Build/Iterate)

```bash
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

```bash
#Step 1 - Execute Permission to tap-cluster.sh file
chmod +x /tap-scripts/tap-cluster.sh

#Step 2 - Execute tap-cluster.sh file 
./tap-scripts/tap-cluster.sh -c tap-view
```

* **To install Run profile only , execute following step**

```bash
#Step 1 - Execute Permission to tap-cluster.sh file
chmod +x /tap-scripts/tap-cluster.sh

#Step 2 - Execute tap-cluster.sh file 
./tap-scripts/tap-cluster.sh -c tap-run
```

* **To install build profile only , execute following step**

```bash
#Step 1 - Execute Permission to tap-cluster.sh file
chmod +x /tap-scripts/tap-cluster.sh

#Step 2 - Execute tap-cluster.sh file 
./tap-scripts/tap-cluster.sh -c tap-build
```

* **To install iterate profile only , execute following step**

```bash
#Step 1 - Execute Permission to tap-cluster.sh file
chmod +x /tap-scripts/tap-cluster.sh

#Step 2 - Execute tap-cluster.sh file 
./tap-scripts/tap-cluster.sh -c tap-iterate
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

```bash
1. execute chmod +x /tap-scripts/tap-delete/tap-delete.sh
2. execute ./tap-scripts/tap-delete/tap-delete.sh
 
# Delete single tap cluster instance 
1. Login to eks clusters(view/run/build/iterate) using kubeconfig where you want to delete tap.
2. execute chmod +x /tap-scripts/tap-delete/tap-delete-single-cluster.sh
3. execute ./tap-scripts/tap-delete/tap-delete-single-cluster.sh
```

### Delete EKS clusters instances from eks cluster

Run `terraform destroy` to destroy to delete all aws resources created by terraform. In some instances it is possible that `terraform destroy` will not be able to clean up after a failed Tanzu install. Especially in situations where the management cluster only comes partially up for whatever reason. In this circumstance you can recursively delete the VPCs that failed to get destroyed and use the tags "CreatedBy: Arcas" to find anything that was generated by this terraform.
