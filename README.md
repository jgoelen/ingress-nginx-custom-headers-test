# Ingress NGINX test setup

This repository provides a local environment to test [PR #11709](https://github.com/kubernetes/ingress-nginx/pull/11709) for the Ingress NGINX Controller project.

## Requirements

To run the setup scripts, ensure the following tools are installed:

- [Helm](https://helm.sh)
- [Kind](https://kind.sigs.k8s.io)
- make
- curl

## Setup Instructions

1. Create a new Kind cluster

```bash
./001_setup_kind.sh
```

2. Deploy ingress controller

```bash
./002_deploy_ingress.sh
```

3. Deploy Podinfo application

```bash
./003_deploy_podinfo.sh
```

## Test 1 ✅: Verify Initial Custom Header

The Podinfo app uses a custom response header `X-TEST`, initially set to `v01`. You can confirm this by running the following curl command:

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

You should see `X-TEST: v01` in the response headers 👆.

# Test 2 🔥: Update Custom Header (Fails Initially)

Update the header value to `v02` in the ConfigMap located at [custom-security-headers-configmap.yaml](podinfo-app/templates/custom-security-headers-configmap.yaml) and redeploy the podinfo app:

```bash
./003_deploy_podinfo.sh
```

However, running the curl command again will still show X-TEST: v01 👇🏻:

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
< Date: Mon, 19 Aug 2024 10:12:33 GMT
< Content-Type: application/json; charset=utf-8
< Content-Length: 393
< Connection: keep-alive
< X-Content-Type-Options: nosniff
< X-TEST: v01
< 
{
  "hostname": "podinfo-5965fc9856-87zd9",
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

To apply the update, restart the ingress controller:

```bash
./004_restart_ingress.sh
```

Now, re-run the curl command and verify that the header is updated to v02 👇🏻:

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
< Date: Mon, 19 Aug 2024 10:17:19 GMT
< Content-Type: application/json; charset=utf-8
< Content-Length: 393
< Connection: keep-alive
< X-Content-Type-Options: nosniff
< X-TEST: v02
< 
{
  "hostname": "podinfo-5965fc9856-87zd9",
  "version": "6.6.3",
  "revision": "b0c487c6b217bed8e6a53fca25f6ee1a7dd573e3",
  "color": "#34577c",
  "logo": "https://raw.githubusercontent.com/stefanprodan/podinfo/gh-pages/cuddle_clap.gif",
  "message": "greetings from podinfo v6.6.3",
  "goos": "linux",
  "goarch": "arm64",
  "runtime": "go1.22.3",
  "num_goroutine": "8",
  "num_cpu": "12"
* Connection #0 to host localhost left intact
}
```

# Test 3 ✅: Update Custom header (with fix)

1. Build the image from the PR and upload it to the test cluster:

```bash
./005_build_and_upload_image.sh
```

2. Configure custom image in Helm chart

Update the [values.yaml](ingress-nginx/values.yaml) as follows:

```yaml
ingress:
  controller:
    kind: "DaemonSet"
    image:
      registry: "local"
      image: "controller"
      tag: "1.0.0-dev"
      digest: ""
...
```

3. Redeploy the controller

```bash
./002_deploy_ingress.sh
```

4. Update header value

Change the value of the header to `v03` in the ConfigMap [custom-security-headers-configmap.yaml](podinfo-app/templates/custom-security-headers-configmap.yaml) and redeploy the podinfo app:

```bash
./003_deploy_podinfo.sh
```

5. Verify update

Run the curl command once more:

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
< Date: Mon, 19 Aug 2024 11:14:47 GMT
< Content-Type: application/json; charset=utf-8
< Content-Length: 393
< Connection: keep-alive
< X-Content-Type-Options: nosniff
< X-TEST: v03
< 
{
  "hostname": "podinfo-5965fc9856-87zd9",
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
You should now see `X-TEST: v03` in the response headers 👆.