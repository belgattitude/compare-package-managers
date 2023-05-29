#!/bin/bash

npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-state.gz'

YARN_COMPRESSION_LEVEL=mixed YARN_LOCKFILE_FILENAME=yarn.mixed-compress.lock yarn install
YARN_COMPRESSION_LEVEL=mixed YARN_LOCKFILE_FILENAME=yarn.mixed-compress.lock yarn dedupe

npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-state.gz'

YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.no-compress.lock yarn install
YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.no-compress.lock yarn dedupe

npx -y rimraf@5.0.1 '**/node_modules' '.yarn/install-state.gz'

YARN_NODE_LINKER=pnp YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.pnp.lock yarn install
YARN_NODE_LINKER=pnp YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.pnp.lock yarn dedupe

npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-state.gz'

rm ./pnpm-lock.yaml

pnpm i

pnpm dedupe
