variable "aws_region" {
  description = "AWS region"
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account id e.g., apps or management or aws007"
}

variable "environment" {
  type        = string
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
}

variable "retention" {
  type        = number
  description = "Logs retetion in CloudWatch"
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
}

variable "availability_zones" {
  description = "A list of availability zones for the subnets."
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
}

variable "capacity" {
  description = "Type of EC2 instance OnDemand or Spot"
}

variable "disk_size" {
  description = "Disk Size of the worker node"  
}

variable "endpoint_private_access" {
  description = "Enable Private Access"
}

variable "endpoint_public_access" {
  description = "Enable Public Access"
}

variable "key_pair" {
  description = "Key pair name for EC2 instances"
}

variable "create_eks_cluster" {
  description = "Whether to create the EKS cluster."
  type        = bool
  default     = true
}

#Node Group Variables
variable "instance_types" {
  description = "EC2 instance type for worker nodes"
}

# variable "additional_tags" {
#   description = "Additional tags for resources"
#   type        = map(string)
# }

variable "create_eks_node_group" {
  description = "Whether to create the EKS node group."
  type        = bool
  default     = true
}

variable "ami_type" {
  description = "Whether to create the EKS node group."
 }

variable "node_group_desired_capacity" {
  description = "The desired capacity of the worker node group."
  type        = number
}

variable "node_group_max_capacity" {
  description = "The maximum capacity of the worker node group."
  type        = number
}

variable "node_group_min_capacity" {
  description = "The minimum capacity of the worker node group."
  type        = number
}

variable "cidr_blocks" {
  description = "CIDR block"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}

variable "new_ssh_key_required" {
  description = "Check for new ssh key"
  type = string
  default = "no"
}

variable "readonly_role_arn" {
  description = "ARN of read only role"
  type        = string
  #default = "arn:aws:iam::*:role/OMC_CloudOps"
 }

variable "admin_role_arn"{
description = "ARN of read only role"
  type        = string
  #default = "arn:aws:iam::*:role/OMC_Admins"
 }

##EKS ADD-ONS
variable "addons" {
  type = list(object({
    name    = string
    #version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      #version = var.kube_proxy
    },
    {
      name    = "vpc-cni"
      #version = var.vpc_cni
    },
    {
      name    = "coredns"
      #version = var.coredns
    }
  ]
}
