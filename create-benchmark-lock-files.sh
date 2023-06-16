#!/bin/bash

YARN_VERSION="4.0.0-rc.45"

export PRISMA_SKIP_POSTINSTALL_GENERATE=true PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true HUSKY=0

npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-stat*.gz' '.yarn/unplugged'
YARN_RC_FILENAME=.yarnrc.mixed-compress.yml corepack yarn@${YARN_VERSION} install --inline-builds
YARN_RC_FILENAME=.yarnrc.mixed-compress.yml corepack yarn@${YARN_VERSION} dedupe

npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-stat*.gz' '.yarn/unplugged'

YARN_RC_FILENAME=.yarnrc.no-compress.yml corepack yarn@${YARN_VERSION} install --inline-builds
YARN_RC_FILENAME=.yarnrc.no-compress.yml corepack yarn@${YARN_VERSION} dedupe

npx -y rimraf@5.0.1 '**/node_modules' '.yarn/install-stat*.gz' '.yarn/unplugged'

YARN_RC_FILENAME=.yarnrc.pnp.no-compress.yml corepack yarn@${YARN_VERSION} install --inline-builds
YARN_RC_FILENAME=.yarnrc.pnp.no-compress.yml corepack yarn@${YARN_VERSION} dedupe

npx -y rimraf@5.0.1 '**/node_modules' '.yarn/install-stat*.gz' '.yarn/unplugged'

rm ./pnpm-lock.yaml

pnpm i

pnpm dedupe
