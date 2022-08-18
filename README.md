# Certificate Generation

This tools is a short helper to create certificates.
It should help developers to create certificates valid for developing/debugging applications locally.

## Running the tool

To run the script, just execute

```
./create_certs.sh DOMAIN_NAME
```

For example, to create a certifiacte for app.localhost run:

```
./create_certs.sh app.localhost
```

## Use Cases

I use this tool with a Traefik Reverse Proxy in Docker when using a local setup.
Just mount the certificate in your Traefik container and specify it in Traefik.
One example to use it is as a fallback certificate:

```
tls:
  certificates:
    - certFile: /certs/cert.crt
      keyFile: /certs/cert.key
```
