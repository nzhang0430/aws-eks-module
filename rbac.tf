data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}
terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      #version = "1.14.0"
}
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)

}
resource "kubernetes_cluster_role_v1" "eksreadonly_clusterrole" {
  metadata {
    name = "${var.cluster_name}-eksreadonly-clusterrole"
  }
  rule {
    api_groups = [""] 
    resources  = ["nodes", "namespaces", "pods", "events", "services"]
    verbs      = ["get", "list"]    
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets", "replicasets"]
    verbs      = ["get", "list"]    
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list"]    
  }  
}


resource "kubernetes_cluster_role_binding_v1" "eksreadonly_clusterrolebinding" {
  metadata {
    name = "${var.cluster_name}-eksreadonly-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.eksreadonly_clusterrole.metadata.0.name 
  }
  subject {
    kind      = "Group"
    name      = "eks-readonly-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

locals {
  configmap_roles = [
    {
      rolearn = "${aws_iam_role.node_group_role.arn}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = "${var.admin_role_arn}"
      username = "eks-admin" 
      groups   = ["system:masters"]
    },
    {
      rolearn  = "${var.readonly_role_arn}"
      username = "eks-readonly" 
      groups   = [ "${kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding.subject[0].name}" ]
    },
  ]
  }

resource "kubernetes_config_map_v1_data" "aws_auth" {
  #depends_on = [aws_eks_cluster.eks_cluster]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode(local.configmap_roles)   
  }  
  force = true
}
