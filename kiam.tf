# IAM Role for ServiceAccounts: Kops clusters 

data "aws_iam_policy_document" "external_dns_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "external_dns" {
  count              = var.eks ? 0 : 1
  name               = "external-dns.${var.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume.json
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions = ["route53:ChangeResourceRecordSets"]

    resources = [format(
      "arn:aws:route53:::hostedzone/%s",
      terraform.workspace == local.live_workspace ? "*" : var.hostzone,
    )]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "external_dns" {
  count  = var.eks ? 0 : 1
  name   = "route53"
  role   = aws_iam_role.external_dns.0.id
  policy = data.aws_iam_policy_document.external_dns.json
}
