enableGatewayListenerSets: true
sources:
  - service
  - ingress
  - gateway-httproute
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
service:
  # Annotate the metrics Service so the CP3 ADOT collector's annotation-driven
  # kubernetes-service-endpoints scrape job discovers it (port 7979). CP3 has no
  # Prometheus Operator, so a ServiceMonitor would be inert — annotation-based
  # discovery is the mechanism in use.
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "7979"
priorityClassName: system-cluster-critical
image:
  pullPolicy: IfNotPresent

global:
  security:
    allowInsecureImages: true

extraArgs:
  exclude-record-types: AAAA