data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
data "aws_iam_policy_document" "csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      #variable = "${replace(var.oidc_url, "https://", "")}:aud"
      variable = "${replace(data.tls_certificate.ex.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      #variable = "${replace(var.oidc_url, "https://", "")}:sub"
      variable = "${replace(data.tls_certificate.ex.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = ["arn:aws:iam::data.aws_caller_identity.current.account_id:oidc-provider/${replace(data.tls_certificate.ex.url, "https://", "")}"]
      type        = "Federated"
    }
  }
}

################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
  name               = "eks-ebs-csi-driver-${var.cluster_name}"
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  role       = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

################################################################################
# EBS DRIVER ADDON
################################################################################

resource "aws_eks_addon" "csi_driver" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  #addon_version            = "v1.25.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}
