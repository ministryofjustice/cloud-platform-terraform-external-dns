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
serviceAccount:
  create: true
  name: external-dns
%{ if eks ~}
  annotations:
    eks.amazonaws.com/role-arn: "${eks_service_account}"
%{ endif ~}
txtPrefix: "_external_dns."
txtOwnerId: ${cluster}
logLevel: info
policy: sync
podAnnotations:
  iam.amazonaws.com/role: "${iam_role}"
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
