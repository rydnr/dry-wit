#!/usr/bin/env bash
# Sets up the local dry-wit environment for tests.
# Copies modules and binaries into ~/.dry-wit/src so that the
# test suite can run using the local sources.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${HOME}/.dry-wit/src"

mkdir -p "${DEST}/modules/ext"

# Copy core modules and extension modules
cp "${REPO_ROOT}/src/modules"/*.dw "${DEST}/modules/"
if [ -d "${REPO_ROOT}/src/modules/ext" ]; then
  cp "${REPO_ROOT}/src/modules/ext"/*.dw "${DEST}/modules/ext/" 2>/dev/null || true
fi

# Copy the main executables
to_copy=("dry-wit" "dry-wit-test")
for bin in "${to_copy[@]}"; do
  cp "${REPO_ROOT}/src/${bin}" "${DEST}/" && chmod +x "${DEST}/${bin}"
done

printf 'Test environment prepared under %s\n' "${DEST}"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
