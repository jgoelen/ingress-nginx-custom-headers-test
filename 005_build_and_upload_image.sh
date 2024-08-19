#!/bin/bash
cd /tmp

git clone https://github.com/jgoelen/ingress-nginx.git

export TAG="1.0.0-dev"
export REGISTRY="local"
cd ingress-nginx
make build image

kind load docker-image local/controller:1.0.0-dev  --name test

