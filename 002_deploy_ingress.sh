#!/bin/bash
cd ingress-nginx
helm upgrade --install --kubeconfig ~/.kube/test-kind.yaml --create-namespace -n ingress-nginx ingress-nginx .