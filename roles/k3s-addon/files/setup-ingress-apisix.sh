#!/bin/bash

ingress_ip=$1

helm repo add apisix https://charts.apiseven.com || echo true
helm repo update
kubectl create ns ingress || echo true
cat > values.yaml << EOF
service:
  type: NodePort
  externalIPs:
    - $ingress_ip
  http:
    enabled: true
    servicePort: 80
  tls:
    servicePort: 443
    nodePort: 443
apisix:
  ssl:
    enabled: true
  prometheus:
    enabled: true
ingress-controller:
  enabled: true
  config:
    apisix:
      serviceNamespace: "ingress"
    kubernetes:
      enableGatewayAPI: true
metrics:
  serviceMonitor:
    enabled: true
    namespace: "ingress"
EOF
helm upgrade --install apisix apisix/apisix --namespace ingress -f values.yaml
