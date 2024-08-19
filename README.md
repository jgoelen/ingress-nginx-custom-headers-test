# Ingress NGINX test setup

This repository contains a local setup for testing [PR #11709](https://github.com/kubernetes/ingress-nginx/pull/11709) of the Ingress NGINX Controller project.

## Requirements

The following tools are required for running the scripts:

- [Helm](https://helm.sh)
- [Kind](https://kind.sigs.k8s.io)

## Getting started

Create a new Kind cluster:

```bash
./001_setup_kind.sh
```

Deploy the latest version of the ingress-nginx controller:

```bash
./002_deploy_ingress.sh
```

Deploy the podinfo application:

```bash
./003_deploy_podinfo.sh
```

## Test 1 ✅

The podinfo-app uses a custom response header `X-TEST` and the initial value is `v01`. This can be verified with the following curl command:

```bash
curl -v -H "Host: podinfo.local" localhost:8001
* Host localhost:8001 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:8001...
* Connected to localhost (::1) port 8001
> GET / HTTP/1.1
> Host: podinfo.local
> User-Agent: curl/8.7.1
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
< Date: Mon, 19 Aug 2024 09:48:09 GMT
< Content-Type: application/json; charset=utf-8
< Content-Length: 393
< Connection: keep-alive
< X-Content-Type-Options: nosniff
< X-TEST: v01
< 
{
  "hostname": "podinfo-5965fc9856-k9h4g",
  "version": "6.6.3",
  "revision": "b0c487c6b217bed8e6a53fca25f6ee1a7dd573e3",
  "color": "#34577c",
  "logo": "https://raw.githubusercontent.com/stefanprodan/podinfo/gh-pages/cuddle_clap.gif",
  "message": "greetings from podinfo v6.6.3",
  "goos": "linux",
  "goarch": "arm64",
  "runtime": "go1.22.3",
  "num_goroutine": "9",
  "num_cpu": "12"
* Connection #0 to host localhost left intact
}
```
