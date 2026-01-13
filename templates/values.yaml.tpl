sources:
  - service
  - ingress
interval: '${sync_interval}'
triggerLoopOnEvent: true
provider: aws
aws:
  region: eu-west-2
  zoneType: public
  batchChangeSize: 4000
  zonesCacheDuration: '${aws_zone_cache_duration}'
domainFilters:
%{ for d in domainFilters ~}
  - ${d}
%{ endfor ~}
regexDomainFilter: '${productionRegexDomainFilter}'
regexDomainExclusion: '${productionRegexDomainExclusion}'
rbac:
  create: true
  apiVersion: v1
serviceAccount:
  create: true
  name: external-dns
  annotations:
    eks.amazonaws.com/role-arn: "${eks_service_account}"
txtPrefix: "${txtPrefix}"
txtOwnerId: ${cluster}
logLevel: info
policy: sync
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
priorityClassName: system-cluster-critical
image:
  registry: docker.io
  repository: bitnamilegacy/external-dns
  tag: 0.18.0-debian-12-r4
  pullPolicy: IfNotPresent


########################################
# bitnami legacy images issue:
#
# Bitnami's introduction of 'production-ready' secure images topic:
# https://github.com/bitnami/charts/issues/35164
# 
# As a temp measure we are switching over to legacy registry. This means the chart complains about insecure images (this is by Bitnami design):
#
# ERROR: Original containers have been substituted for unrecognized ones. Deploying this chart with non-standard containers is likely to cause degraded security and performance, broken chart features, and missing environment variables.
# 
# Unrecognized images:
#    - docker.io/bitnamilegacy/external-dns:0.15.1-debian-12-r1
#
# If you are sure you want to proceed with non-standard containers, you can skip container image verification by setting the global parameter 'global.security.allowInsecureImages' to true.
# Further information can be obtained at https://github.com/bitnami/charts/issues/30850
#
# Therefore we are setting: 
# global.security.allowInsecureImages: true
# 
# This solution will only help us until we pass version 0.18 of external-dns:
# https://hub.docker.com/r/bitnamilegacy/external-dns/tags
#
# After which we need to do something else:
# 
# - switch to kubernetes-sigs chart (effort required, different config/syntax)
# - subscribe to bitnami?
#
########################################
global:
  security:
    allowInsecureImages: true

extraArgs:
  exclude-record-types: AAAA