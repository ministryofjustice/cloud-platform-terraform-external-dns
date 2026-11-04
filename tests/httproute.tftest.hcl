mock_provider "helm" {}

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"route53:ListHostedZones\",\"Resource\":\"*\"}]}"
    }
  }
}

override_module {
  target = module.iam_assumable_role_admin
  outputs = {
    iam_role_arn = "arn:aws:iam::123456789012:role/external-dns-test"
  }
}

variables {
  cluster_domain_name         = "test.cloud-platform.service.justice.gov.uk"
  hostzones                   = ["arn:aws:route53:::hostedzone/TEST"]
  domain_filters              = ["test.cloud-platform.service.justice.gov.uk"]
  eks_cluster_oidc_issuer_url = "https://oidc.eks.eu-west-2.amazonaws.com/id/TEST"
}

run "test_cluster_sources_and_ownership" {
  command = plan

  variables {
    is_live_cluster = false
  }

  assert {
    condition     = yamldecode(helm_release.external_dns.values[0]).sources == ["service", "ingress", "gateway-httproute"]
    error_message = "HTTPRoute discovery must be added without removing Service or Ingress discovery."
  }

  assert {
    condition = (
      yamldecode(helm_release.external_dns.values[0]).policy == "sync" &&
      yamldecode(helm_release.external_dns.values[0]).txtOwnerId == terraform.workspace &&
      yamldecode(helm_release.external_dns.values[0]).txtPrefix == "_external_dns.%%{record_type}." &&
      yamldecode(helm_release.external_dns.values[0]).domainFilters == ["test.cloud-platform.service.justice.gov.uk"]
    )
    error_message = "Existing DNS ownership, domain filters and sync policy must remain unchanged."
  }

  assert {
    condition = (
      helm_release.external_dns.version == "9.0.3" &&
      yamldecode(helm_release.external_dns.values[0]).image.repository == "bitnamilegacy/external-dns" &&
      yamldecode(helm_release.external_dns.values[0]).image.tag == "0.18.0-debian-12-r4" &&
      yamldecode(helm_release.external_dns.values[0]).interval == "60m" &&
      yamldecode(helm_release.external_dns.values[0]).rbac.create
    )
    error_message = "Retain the existing chart, image, test-cluster interval and chart-managed RBAC."
  }
}

run "production_filters_and_interval" {
  command = plan

  assert {
    condition = (
      yamldecode(helm_release.external_dns.values[0]).sources == ["service", "ingress", "gateway-httproute"] &&
      yamldecode(helm_release.external_dns.values[0]).interval == "10m" &&
      yamldecode(helm_release.external_dns.values[0]).regexDomainFilter == ".*" &&
      yamldecode(helm_release.external_dns.values[0]).regexDomainExclusion == "cp-.*-.*\\.cloud-platform\\.service\\.justice\\.gov\\.uk$|yy-.*-.*\\.cloud-platform\\.service\\.justice\\.gov\\.uk$"
    )
    error_message = "HTTPRoute discovery must preserve production domain exclusions and reconciliation interval."
  }
}
