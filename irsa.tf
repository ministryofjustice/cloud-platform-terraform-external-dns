
# IAM Role for ServiceAccounts: EKS clusters

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.13.0"
  create_role                   = true
  role_name                     = "external-dns.${var.cluster_domain_name}"
  provider_url                  = var.eks_cluster_oidc_issuer_url
  role_policy_arns              = [length(aws_iam_policy.external_dns) >= 1 ? aws_iam_policy.external_dns.arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:external-dns"]
}

resource "aws_iam_policy" "external_dns" {

  name_prefix = "external_dns"
  description = "Policy that allows change DNS entries for the externalDNS servicefor {var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.external_dns_irsa.json
}

data "aws_iam_policy_document" "external_dns_irsa" {
  statement {
    actions = ["route53:ChangeResourceRecordSets"]

    resources = var.hostzones
  }

  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
}
