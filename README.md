# Public Edge Manager

This chart packages the `PublicEdge` inventory, health authority and DNS answer
service as one application. It does not write Cloudflare records directly.
ExternalDNS remains the publication executor for NS/glue ownership, while this
authority answers delegated service names from live `PublicEdge` health.
For names that are not yet delegated, one elected manager patches a single
ExternalDNS-only Ingress with the healthy default-area target. Application
HTTPRoute/TLSRoute objects must not also carry ExternalDNS eligibility.

Selection is deterministic:

1. unhealthy, disabled and draining edges are excluded;
2. a healthy edge in the querying NS replica's coarse `area` (CN/US/EU/APAC)
   always beats a remote edge;
3. inside an area, `capacityMbps` is the dominant score, followed by explicit
   priority and measured application latency;
4. a `RegionalRelay` publishes its local public endpoint but forwards traffic
   to the declared origin area/Gateway VIP.

The chart ships without organization-specific nameservers, nodes, services or
edges. Supply them in your own values file; `examples/values-re8ch.yaml` shows
the configuration that was previously embedded in the chart defaults.
Set `enabled=true` after providing that inventory. The explicit opt-in prevents
an empty release from binding DNS port 53 on every node.

## Security defaults

The manager receives read-only access to Ingress objects by default. Set
`rbac.mutateIngresses=true` only when using the legacy publication mode that
patches an ExternalDNS-only Ingress. Delegated authoritative DNS does not need
that permission.

The DNS Service exposes both TCP and UDP port 53 in addition to the health API.
Its type, annotations and external traffic policy are configurable.

## Container image and licensing

The current default image is hosted at `registry.re8ch.com`. Operators should
pin `image.digest` and verify that their cluster can pull it before installing.
The controller source and a repository-level license file should be published
before third parties treat this chart as a supply-chain-verifiable release.
