#!/bin/sh
set -eu

chart_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

helm lint "$chart_dir"
helm lint "$chart_dir" -f "$chart_dir/examples/values-gzsj.yaml" --set enabled=true

helm template public-edge-manager "$chart_dir" > "$work_dir/disabled.yaml"
test "$(grep -c '^kind:' "$work_dir/disabled.yaml")" -eq 1
grep -q '^kind: CustomResourceDefinition$' "$work_dir/disabled.yaml"

helm template public-edge-manager "$chart_dir" \
  -f "$chart_dir/examples/values-gzsj.yaml" --set enabled=true \
  > "$work_dir/enabled.yaml"
grep -q 'headlamp.47-113-185-212.sslip.io' "$work_dir/enabled.yaml"
grep -q 'public-edge.47-113-185-212.sslip.io' "$work_dir/enabled.yaml"

if helm template duplicate-test "$chart_dir" \
  -f "$chart_dir/tests/duplicate-domain-values.yaml" \
  > "$work_dir/duplicate.yaml" 2> "$work_dir/duplicate.err"; then
  echo "expected duplicate domain configuration to fail" >&2
  exit 1
fi
grep -q 'configured in both domains and services' "$work_dir/duplicate.err"
