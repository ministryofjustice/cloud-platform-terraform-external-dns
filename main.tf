locals {
  live_workspace = "live-1"
}

resource "helm_release" "external_dns" {
  name      = "external-dns"
  chart     = "stable/external-dns"
  namespace = "kube-system"
  version   = "2.6.4"

  values = [
    <<EOF
image:
  tag: 0.5.17-debian-9-r0
sources:
  - service
  - ingress
provider: aws
aws:
  region: eu-west-2
  zoneType: public
domainFilters:
  ${terraform.workspace == local.live_workspace ? "" : format(
    "- %s",
    data.terraform_remote_state.cluster.outputs.cluster_domain_name,
)}
rbac:
  create: true
  apiVersion: v1
  serviceAccountName: default
txtPrefix: "_external_dns."
logLevel: info
podAnnotations:
  iam.amazonaws.com/role: "${aws_iam_role.external_dns.name}"
EOF
,
]

depends_on = [
  helm_release.kiam,
  var.dependence_deploy,
  var.dependence_prometheus,
  var.dependence_opa,
]

lifecycle {
  ignore_changes = [keyring]
}
}
