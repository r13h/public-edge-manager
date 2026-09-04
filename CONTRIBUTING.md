# Contributing

Contributions are welcome through GitHub pull requests. Keep product defaults
free of organization-specific domains, addresses, credentials, and topology.

Before opening a pull request, run:

```sh
python -m unittest discover -s tests -v
helm lint .
helm lint . -f examples/values-example.yaml
helm template public-edge-manager . -f examples/values-example.yaml >/dev/null
docker build .
```

By contributing, you agree that your contribution is licensed under Apache-2.0.
