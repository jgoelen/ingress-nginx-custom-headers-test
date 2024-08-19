#!/bin/bash
kind create cluster --name test --config kind-config.yaml --wait 1m
kind get kubeconfig -n test > ~/.kube/test-kind.yaml