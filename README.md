
# AWS EKS Terraform module

AWS EKS Terraform module
Terraform module which creates AWS EKS (Kubernetes) resources.
 




## Introduction

The module provisions the following resources:

•	 EKS cluster of master nodes that can be used together with the terraform-aws-eks-workers terraform-aws-eks-node-group modules to create a complete EKS cluster.

• 	IAM Role and OIDC Provider to allow the cluster access other AWS services.

•	 The module creates an authentication ConfigMap (aws-auth) to allow the worker nodes to join the cluster and to add additional users/roles/accounts. 

•	 EBS CSI Driver addon which manages the lifecycle of Amazon EBS volumes as storage for the Kubernetes Volumes that you create.

• 	Other Network Driver addons which include vpc-cni,kube-proxy and coredns.



EKS Cluster creation 


## Inputs

#### Get all items


| Name | Type     | Description 
| :-------- | :------- | :------------------------- |
| "aws_region" | `string` | **Required**. AWS Region |
| "tenant" | `string` | **Required**. Account Name or unique account id e.g., apps or management |
| "environment" | `string` | **Required**.Environment area, e.g. prod or preprod  |
| "zone" | `string` | **Required**. zone, e.g. dev or qa or load or ops etc... |
| "cluster_name" | `string` | **Required**. Name for the EKS cluster |
| "subnet_ids" | `list(string)` | **Required**. List of subnet IDs for EKS cluster |
| "vpc_id" | `string` | **Required**. VPC ID for the EKS cluster |
| "availability_zones" | `list(string)` | **Required**. A list of availability zones for the subnets. |
| "cluster_version" | `string` | **Required**. Kubernetes version for the EKS cluster |
| "capacity" | `string` | **Required**. Type of EC2 instance OnDemand or Spot |
| "disk_size" | `string` | **Required**.Disk Size of the worker node |
| "endpoint_private_access" | `boolean` | **Required**. Enable Private Access |
| "endpoint_public_access" | `boolean` | **Required**. Enable Public Access |
| "key_pair" | `string` | **Required**. Key pair name for EC2 instances |
| "variable "create_eks_cluster"| `boolean` | **Optional**. Whether to create the EKS cluster where default is et as True|
| "image" | `string` | **Required**. Image of ALB Ingress controller|
| "retention" | `number` | **Required**. Logs retetion in CloudWatch|

#### Node Group Variables

| Name | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| "instance_types"      | `string` | **Required**. EC2 instance type for worker nodes |
| "variable "create_eks_node_group"| `Boolean` | **Optional**.Whether to create the EKS node group where default is set as True. |
| "ami_type"      | `string` | **Required**. Whether to create the EKS node group. |
| "node_group_desired_capacity"      | `number` | **Required**. The desired capacity of the worker node group.|
| "node_group_max_capacity"      | `number` | **Required**. The maximum capacity of the worker node group. |
| "node_group_min_capacity"      | `number` | **Required**. The minimum capacity of the worker node group. |
| "cidr_blocks"      | `list(string)` | **Required**. CIDR block. |
| "tags"      | `map(string)` | **Required**. A map of tags (key-value pairs) passed to resources. |
| "new_ssh_key_required"      | `string` | **Optional**. Check for new ssh key where default is No. |
| "readonly_role_arn"      | `string` | **Required**. ARN of read only role. |
| "admin_role_arn"      | `string` | **Required**. ARN of read only role. |


#### Addon variables

| Name | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| "kube_proxy"      | `string` | **Required**. kube_proxy version which you want to use |
| "vpc_cni"      | `string` | **Required**. vpc_cni version which you want to use |
| "coredns"      | `string` | **Required**. coredns version which you want to use |

## Outputs

| Name | Description |
| :-------- | :-------------------------------- |
| "eks_cluster_version"      | The Kubernetes server version of the cluster 
| "eks_cluster_id"     | The name of the cluster
| "eks_cluster_certificate_authority_data"   | EKS cluster certificate authority data
| "eks_cluster_endpoint"     | EKS cluster endpoint

## Usage/Examples

```javascript
module "eks" {
source           = "./modules/eks"
aws_region      = "ap-northeast-1"
tenant            = "mci"
environment       = "stage"
zone              = "nonprod"
availability_zones      = ["ap-northeast-1a", "ap-northeast-1b"]
cluster_version     = "1.27"
instance_types      = ["m5.2xlarge"]
cluster_name        = "mciaan1-stage-eks01"
vpc_id              = "vpc-02a6134a36d1d9b6b"
subnet_ids          = ["subnet-01b3ed1e7dc32bb39","subnet-08a086583f092f8d3"]
ami_type                = "AL2_x86_64"
disk_size               = 50
capacity                = "ON_DEMAND"
node_group_desired_capacity = 2
node_group_max_capacity = 2
node_group_min_capacity = 2
endpoint_private_access = true
endpoint_public_access  = true
key_pair                = "mci_stage_key"
readonly_role_arn       = "arn:aws:iam::063790484145:role/OMC_CloudOps"
admin_role_arn          = "arn:aws:iam::063790484145:role/OMC_Admins"
cidr_blocks             = ["0.0.0.0/0"]
retention               = 30
image                   = "602401143452.dkr.ecr.ap-northeast-1.amazonaws.com"
  tags = merge(
    var.tags, { 
    Environment = "Lab"
    cluster_name = var.cluster_name
    cluster_version = var.cluster_version
    Created_by      = "Terraform"
  })
 }
```

## Requirements

| Name             | Version                                                                |
| ----------------- | ------------------------------------------------------------------ |
|terraform | >= 1.3.7 |
| aws | >= 5.24.0 |
| kubernetes | >= 2.10 |
| tls | >= 3.0 |



