#!/bin/bash
cd podinfo-app
helm upgrade --kubeconfig ~/.kube/test-kind.yaml --install -f values.yaml --create-namespace -n podinfo podinfo .