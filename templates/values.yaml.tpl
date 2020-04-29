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
%{ for d in domainFilters ~}
  - ${d}
%{ endfor ~}
rbac:
  create: true
  apiVersion: v1
  serviceAccountName: default
txtPrefix: "_external_dns."
txtOwnerId: ${cluster}
logLevel: info
podAnnotations:
  iam.amazonaws.com/role: "${iam_role}"
