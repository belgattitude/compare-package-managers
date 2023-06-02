#!/bin/bash

export PRISMA_SKIP_POSTINSTALL_GENERATE=true PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true HUSKY=0


npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-state*.gz'

YARN_RC_FILENAME=.yarnrc.mixed-compress.yml yarn install --inline-builds
YARN_RC_FILENAME=.yarnrc.mixed-compress.yml yarn dedupe

npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/install-state*.gz'

YARN_RC_FILENAME=.yarnrc.no-compress.yml yarn install --inline-builds
YARN_RC_FILENAME=.yarnrc.no-compress.yml yarn dedupe

npx -y rimraf@5.0.1 '**/node_modules' '.yarn/install-state*.gz'

YARN_RC_FILENAME=.yarnrc.pnp.no-compress.yml yarn install --inline-builds
YARN_RC_FILENAME=.yarnrc.pnp.no-compress.yml yarn dedupe

npx -y rimraf@5.0.1 '**/node_modules' '.yarn/install-state*.gz'

rm ./pnpm-lock.yaml

pnpm i

pnpm dedupe
