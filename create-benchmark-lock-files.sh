#!/bin/bash

npx rimraf@3 '*.lock'

rm -f '.yarn/install-state.gz'
npx rimraf@3 '**/node_modules'

YARN_COMPRESSION_LEVEL=mixed YARN_LOCKFILE_FILENAME=yarn.mixed-compress.lock yarn install
YARN_COMPRESSION_LEVEL=mixed YARN_LOCKFILE_FILENAME=yarn.mixed-compress.lock yarn dedupe

rm -f '.yarn/install-state.gz'
npx rimraf@3 '**/node_modules'

YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.no-compress.lock yarn install
YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.no-compress.lock yarn dedupe

rm -f '.yarn/install-state.gz'
npx rimraf@3 '**/node_modules'

YARN_NODE_LINKER=pnp YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.pnp.lock yarn install
YARN_NODE_LINKER=pnp YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.pnp.lock yarn dedupe

npx rimraf@3 '**/node_modules'

rm ./pnpm-lock.yaml

pnpm i
