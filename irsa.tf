
# IAM Role for ServiceAccounts: EKS clusters

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = var.eks ? true : false
  role_name                     = "external-dns.${var.cluster_domain_name}"
  provider_url                  = var.eks_cluster_oidc_issuer_url
  role_policy_arns              = [var.eks ? aws_iam_policy.external_dns.0.arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:external-dns:external-dns"]
}

resource "aws_iam_policy" "external_dns" {
  count = var.eks ? 1 : 0

  name_prefix = "external_dns"
  description = "EKS cluster-autoscaler policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.external_dns_irsa.json
}

data "aws_iam_policy_document" "external_dns_irsa" {
  statement {
    actions = ["route53:ChangeResourceRecordSets"]

    resources = var.hostzone
  }

  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}
