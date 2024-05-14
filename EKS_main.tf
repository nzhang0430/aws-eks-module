#Create an IAM role for the EKS cluster
resource "aws_iam_role" "cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the necessary policy for EKS cluster
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_VPC_Controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_cloudwatch_log_group" "cluster_cloudwatch" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.retention
}

# Create AWS EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  tags = var.tags

  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    security_group_ids      = [aws_security_group.node_group_one.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.cluster_VPC_Controller_policy,
    aws_cloudwatch_log_group.cluster_cloudwatch
  ]
}

##########################################################################################
######################################NODE GROUP SETUP####################################
##########################################################################################

# Create an IAM role for the EKS node group
resource "aws_iam_role" "node_group_role" {
  name = "${var.cluster_name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the necessary policy for EKS node group
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

#Create the EKS node group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-wng-01"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = var.subnet_ids
  tags            = var.tags

  scaling_config {
    desired_size = var.node_group_desired_capacity
    max_size     = var.node_group_max_capacity
    min_size     = var.node_group_min_capacity
  }

  ami_type       = var.ami_type
  capacity_type  = var.capacity
  disk_size      = var.disk_size
  instance_types = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.node_group_one.id]
    ec2_ssh_key               = var.key_pair
  }


  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_readonly_policy,
    aws_eks_cluster.eks_cluster
  ]
}

resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = var.cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "tls_certificate" "ex" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "ex" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.ex.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.ex.url
}
output "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value = aws_iam_openid_connect_provider.ex.arn 
}
locals {
    oidc_id = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.ex.arn}"), 1)
}

output "oidc_connect_id" {
  description = "AWS IAM Open ID Connect Provider "
   value = local.oidc_id
}
