#!/bin/bash
kubectl --kubeconfig ~/.kube/test-kind.yaml rollout restart -n ingress-nginx daemonset/ingress-nginx-controller