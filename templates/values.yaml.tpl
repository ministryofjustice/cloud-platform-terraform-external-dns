sources:
  - service
  - ingress
interval: 10m
triggerLoopOnEvent: true
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
  annotations:
    eks.amazonaws.com/role-arn: "${eks_service_account}"
txtPrefix: "_external_dns."
txtOwnerId: ${cluster}
logLevel: info
policy: sync
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
