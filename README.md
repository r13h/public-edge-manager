# Public Edge Manager

Public Edge Manager is an open-source Kubernetes controller and authoritative
DNS service for selecting healthy public ingress edges by locality, capacity,
priority, and observed application latency. It is application- and DNS-provider
agnostic: operators supply their own zones, services, nodes, endpoints, Gateway
VIPs, and publication integration.

The repository is the complete build context. It contains the controller source,
tests, container definition, Helm chart, license, and CI/release workflows. It
does not require code or ConfigMaps from a separate private repository.

## How it works

1. Disabled, draining, and unhealthy edges are excluded.
2. A healthy edge in the authority replica's configured area beats a remote edge.
3. Capacity, priority, application latency, and a small node-local preference
   provide deterministic ordering inside an area.
4. DNS A or CNAME answers publish the best equally scored candidates.
5. An optional legacy mode updates explicitly named ExternalDNS-only Ingresses.

Public Edge Manager does not configure routers, NAT, BGP, certificates, or
application Gateways. Those remain explicit operator-owned infrastructure.

## Install

Start from [`examples/values-example.yaml`](examples/values-example.yaml), replace
all documentation addresses and names, then install the OCI chart:

```sh
helm install public-edge-manager \
  oci://ghcr.io/re8ch/charts/public-edge-manager \
  --version 0.3.0 \
  --namespace public-edge-system --create-namespace \
  --values values-production.yaml
```

The chart defaults to `enabled: false`; enabling it requires at least one
nameserver, authority node, service, and edge. `api.group` is configurable for
organizations that own a Kubernetes API group. Existing installations can keep
`networking.re8ch.com` for API compatibility without using any RE8CH service
domain or infrastructure.

## Exposure and security model

The chart creates two Services:

- `public-edge-manager-dns` carries only authoritative UDP/TCP 53 and may be
  configured as `LoadBalancer`.
- `public-edge-manager` is always `ClusterIP` and carries the health/discovery
  HTTP API on port 8080.

Ingress mutation is disabled by default. Enable `publication.enabled` and
`rbac.mutateIngresses` together only for the legacy ExternalDNS publication
mode. Normal delegated authoritative DNS requires read-only Ingress access.

The controller runs as UID/GID 65532 with a read-only root filesystem, no
privilege escalation, and only `NET_BIND_SERVICE`. Never put credentials or
private topology in chart defaults.

## Artifact verification

Tagged releases publish multi-architecture images and OCI Helm charts to GHCR.
Images include GitHub provenance and SBOM attestations and are signed keylessly
with Sigstore. Pin the resolved image digest in production:

```sh
cosign verify \
  --certificate-identity-regexp '^https://github.com/re8ch/public-edge-manager/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ghcr.io/re8ch/public-edge-manager@sha256:...
```

See [`SECURITY.md`](SECURITY.md) for vulnerability reporting and
[`CONTRIBUTING.md`](CONTRIBUTING.md) for validation requirements.

## License

Apache License 2.0. See [`LICENSE`](LICENSE).
