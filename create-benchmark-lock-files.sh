#!/bin/bash

BENCH_YARN_VERSION=4.0.0-rc.47
BENCH_PNPM_VERSION=8.6.5

export PRISMA_SKIP_POSTINSTALL_GENERATE=true PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true HUSKY=0

npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-stat*.gz' '.yarn/unplugged' '/tmp/xfs-*' '.yarn/unplugged'

COREPACK_ENABLE_STRICT=0 YARN_LOCKFILE_FILENAME=yarn.mixed-compress.lock YARN_RC_FILENAME=.yarnrc.mixed-compress.yml YARN_COMPRESSION_LEVEL=mixed YARN_CACHE_FOLDER=.yarn/benchmark-cache/mixed-compress corepack yarn@${BENCH_YARN_VERSION} install --inline-builds
COREPACK_ENABLE_STRICT=0 YARN_LOCKFILE_FILENAME=yarn.mixed-compress.lock YARN_RC_FILENAME=.yarnrc.mixed-compress.yml YARN_COMPRESSION_LEVEL=mixed YARN_CACHE_FOLDER=.yarn/benchmark-cache/mixed-compress corepack yarn@${BENCH_YARN_VERSION} dedupe

npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-stat*.gz' '.yarn/unplugged' '/tmp/xfs-*' '.yarn/unplugged'

COREPACK_ENABLE_STRICT=0 YARN_LOCKFILE_FILENAME=yarn.no-compress.lock YARN_RC_FILENAME=.yarnrc.no-compress.yml YARN_COMPRESSION_LEVEL=0 YARN_CACHE_FOLDER=.yarn/benchmark-cache/no-compress corepack yarn@${BENCH_YARN_VERSION} install --inline-builds
COREPACK_ENABLE_STRICT=0 YARN_LOCKFILE_FILENAME=yarn.no-compress.lock YARN_RC_FILENAME=.yarnrc.no-compress.yml YARN_COMPRESSION_LEVEL=0 YARN_CACHE_FOLDER=.yarn/benchmark-cache/no-compress corepack yarn@${BENCH_YARN_VERSION} dedupe

npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-stat*.gz' '.yarn/unplugged' '/tmp/xfs-*' '.yarn/unplugged'

# PNP broke with prisma
#COREPACK_ENABLE_STRICT=0 YARN_LOCKFILE_FILENAME=yarn.pnp.no-compress.lock YARN_RC_FILENAME=.yarnrc.pnp.no-compress.yml YARN_CACHE_FOLDER=.yarn/benchmark-cache/pnp-no-compress corepack yarn@${BENCH_YARN_VERSION} install --inline-builds
#COREPACK_ENABLE_STRICT=0 YARN_LOCKFILE_FILENAME=yarn.pnp.no-compress.lock YARN_RC_FILENAME=.yarnrc.pnp.no-compress.yml YARN_CACHE_FOLDER=.yarn/benchmark-cache/pnp-no-compress corepack yarn@${BENCH_YARN_VERSION} dedupe
#npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-stat*.gz' '.yarn/unplugged' '/tmp/xfs-*' '.yarn/unplugged'

rm ./pnpm-lock.yaml

COREPACK_ENABLE_STRICT=0 corepack pnpm@${BENCH_PNPM_VERSION} i

COREPACK_ENABLE_STRICT=0 corepack pnpm@${BENCH_PNPM_VERSION} dedupe
