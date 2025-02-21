#!/bin/bash

set -ux

CREATE_NS=$1
NAMESPACE=jaskaran-dev

if $CREATE_NS; then
    kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io gatekeeper-validating-webhook-configuration
    sleep 10
    kubectl create namespace $NAMESPACE
fi

kubectl delete ing ext-dns-ing-1
kubectl delete ing ext-dns-ing-2
kubectl delete ing ext-dns-ing-3
kubectl delete ing ext-dns-ing-4

# Create an apex record to be checked in the pre upgrade phase
kubectl apply -f fixtures/apex-pre-ing-1.yaml -n $NAMESPACE

# Create an apex record to be checked in the post upgrade phase
kubectl apply -f fixtures/apex-post-ing-2.yaml -n $NAMESPACE

# Create an subdomain record to be checked in the pre upgrade phase
kubectl apply -f fixtures/sub-pre-ing-3.yaml -n $NAMESPACE

# Create an subdomain record to be checked in the post upgrade phase
kubectl apply -f fixtures/sub-post-ing-4.yaml -n $NAMESPACE

sleep 60

exit 0

