image:
  tag: 0.7.1-debian-10-r68
sources:
  - service
  - ingress
provider: aws
aws:
  region: eu-west-2
  zoneType: public
domainFilters:
%{ for d in domainFilters ~}
  - ${d}
%{ endfor ~}
rbac:
  create: true
  apiVersion: v1
  serviceAccountName: external-dns
%{ if eks ~}
  serviceAccountAnnotations:
    eks.amazonaws.com/role-arn: "${eks_service_account}"
%{ endif ~}
txtPrefix: "_external_dns."
txtOwnerId: ${cluster}
logLevel: info
policy: sync
podAnnotations:
  iam.amazonaws.com/role: "${iam_role}"
