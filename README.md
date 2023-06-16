## Compare package managers

Benchs from [pnpm](https://pnpm.io/benchmarks) and [yarn 3+](https://yarnpkg.com/benchmarks) already exists.
Let's test the differences based on [nextjs-monorepo-example](https://github.com/belgattitude/nextjs-monorepo-example)
for fun with GH CI first approach (ubuntu). 

Potential for co2 emissions reductions at install, build and runtime (♻️🌳❤️) ?

> See also 2 interesting gists to help you set up caches on github
> - yarn 4 - https://gist.github.com/belgattitude/042f9caf10d029badbde6cf9d43e400a
> - pnpm 8 - https://gist.github.com/belgattitude/838b2eba30c324f1f0033a797bab2e31


#### 📥 Install speed 

Measured through github actions. See [workflows/ci-install-benchmark.yml](./.github/workflows/ci-install-benchmark.yml) and [latest run](https://github.com/belgattitude/compare-package-managers/actions/runs/5092812836/jobs/9154654118)

- PNPM 8.6.2 - **25s** (16s + 9s for cache fetch / decompress), see [.npmrc](./.npmrc)
- Yarn 4.0.0-rc.44 / nmLinker - **28s** (26s+2s with compressionLevel:0), see [.yarnrc.no-compress.yml](./.yarnrc.no-compress.yml)
- Yarn 4.0.0-rc.44 / nmLinker - **37s** (34s+3s with compressionLevel:mixed), see [.yarnrc.mixed-compress.yml](./.yarnrc.mixed-compress.yml)

**With cache**

| CI Scenario             | Install | CI fetch cache |   Total | Cache size | CI persist cache |
|-------------------------|--------:|---------------:|--------:|-----------:|-----------------:|
| yarn4 mixed-compression |     34s |             3s | **37s** |      201Mb |          *(±5s)* |
| yarn4 no compression    |     26s |             2s | **28s** |      155Mb |          *(±8s)* |
| pnpm8.6.2               |     16s |             9s |  **25s** |      253Mb |         *(±30s)* |

**Without cache**

| CI Scenario                        | Install | Diff with cached run | 
|------------------------------------|--------:|---------------------:|
| yarn4 mixed-compression / no cache |    ±83s |      > 2x slower |
| yarn4 no compression / no cache    |    ±45s |      < 2x slower |
| pnpm8 / no cache                   |    ±48s |       2x slower | 


Globally very close to each other when considering that yarn preserve cache across lock changes. 

**Caution** PNPM does not have an equivalent of supportedArchitectures. In other words docker, vercel,
cache sizes are bigger when using native binaries (swc,esbuild...). In lambdas it can lead to slow startup times too. 

See the action in [.github/workflows/ci-install-benchmark.yml](https://github.com/belgattitude/compare-package-managers/blob/main/.github/workflows/ci-install-benchmark.yml)
and the [history log](https://github.com/belgattitude/compare-package-managers/actions/workflows/ci-install-benchmark.yml). 
 
#### 👬🏽 Dedupe check speed

Recent PNPM has a built-in dedupe like yarn. Dedupe checks are life-savers, what's the time ?

- yarn: instant
- pnpm: need to reinstall (+/- install time) 

#### ⏩ Nextjs build speed and lambda size

Build the nextjs-app [standalone mode](https://nextjs.org/docs/advanced-features/output-file-tracing#automatically-copying-traced-files): **Yarn / Pnpm are equivalent (+/- 1min)**. Curious ? See the action in
[.github/workflows/ci-build-benchmark.yml](https://github.com/belgattitude/compare-package-managers/blob/main/.github/workflows/ci-build-benchmark.yml) and
the [history log](https://github.com/belgattitude/compare-package-managers/actions/workflows/ci-build-benchmark.yml)

On the pnpm side, it's more complex cause 

- In many cases you'll have to run install with `auto-install-peers=true` or in `hoisted` mode to circumvent issues with some libraries. When doing this, expect rather slow installs (ie prisma without hacks, ...).
- Nextjs standalone mode often breaks with pnpm
- As pnpm/npm does not yet support supportedArchitectures, expect bigger lambda size (slow cold start). Nextjs/prisma tries to clean that up, but yarn does a better job (no more prisma binaries for glibc + musl, etc)

See the section "Debug size" in [.github/workflows/ci-build-benchmark.yml](https://github.com/belgattitude/compare-package-managers/blob/main/.github/workflows/ci-build-benchmark.yml) and
the [history log](https://github.com/belgattitude/compare-package-managers/actions/workflows/ci-build-benchmark.yml)

#### 🔢 Install size (in monorepo)

If you're not using nextjs (with standalone mode) things are different. Yarn does a better job at deduping and
also avoid installing native binaries (ie: glibc, musl) thx to [supportedArchitectures](https://yarnpkg.com/configuration/yarnrc#supportedArchitectures).
See also: https://github.com/pnpm/pnpm/issues/5504.

#### 🦺 Safe to use ?

They differ in the hoisting structure and the peer-dependency strategy. Expect different kind of edge cases. In my 
experience pnpm is sometimes harder to work with (ie prisma)

### Technicalities

- [Yarn 4.0.0-rc.44](https://yarnpkg.com/) - "Safe, stable, reproducible projects".
- [Pnpm 8.6.2](https://pnpm.io/) - "Fast, disk space efficient package manager".

Yarn support 3 module resolution algorithms (often called hoisting): node_modules, pnp and pnpm (alpha). Only the
`nodeLinker: node-modules` have been included in this test to prevent any compatibility issues. 
Keep in mind that the pnp linker will be the fastest in install and will even bring speedups at runtime.

Pnpm is a fast moving package manager recently endorsed by vercel that plays well in monorepos. 

### Aspects

- Reproducible ? 
  - Yarn lightweight js binary is committed within the repo (<3mb). That avoid bugs due to
    difference in versions. PNPM is too big to be stored in the repo, you need to install it.
    The experimental [corepack](https://nodejs.org/api/corepack.html)
    will bring solution to this. Both package managers already support corepack, but there's some time before a stable ecosystem shift.
  - Yarn is very picky about strictness, checksums... it's quite difficult to abuse. Something that is generally preferred in the enterprise world. 

- Fast ? 
  - On CI what makes the biggest different is to set up a cache. Simple and easy. 
    See [pnpm cache gist](https://gist.github.com/belgattitude/838b2eba30c324f1f0033a797bab2e31) and [yarn cache gist](https://gist.github.com/belgattitude/042f9caf10d029badbde6cf9d43e400a),
    that gives a >2x boost.    
  - It's super difficult to compare this. I would say in simple scenarios or whenever you deal with many versions of the same dep: PNPM rules. In monorepos with a couple of 'native' deps (ie: prisma, swc, esbuild...) Yarn should be faster.    
    
- Space efficient ? 
  - PNPM helps when many versions of the same library co-exists (ie: lodash...). It only stores
    the files that differs (creates a symlink instead). It might help in those situations (a symlink is 4kb so
    it gives best results if non-changed files are more than 4kb). So useful is some specific scenarios.
    In measurements yarn seems to use less space.
  - PNPM handles peer-deps differently. In some aspects it's more solid than yarn with node_modules
    but it does not dedupe them (leading to more versions installed). 
  - Yarn offers `supportedArchitectures`. When configured to current, it helps to not download native binaries for
    other platforms (ie: amd64 + musl for esbuild, swc...)

### Scenarios

The following have been tested on CI. Look for the results in the action history:

See results in [actions](https://github.com/belgattitude/compare-package-managers/actions)


## Want to test locally ?

Use [hyperfine](https://github.com/sharkdp/hyperfine) and [taskset](https://man7.org/linux/man-pages/man1/taskset.1.html) 
to mimic ci two-cores speed.


### Compare pnpm / yarn

> **Warning** this is native speed with cache, but it does not take into account the cache persistence
> on a CI. 
> 
> Yarn has a much lower overhead on @action/cache than pnpm 
> - fetch/persist - less and smaller files to compress: 
>      - yarn cache =  2.234 zip files (mixed compression = 227Mb, no compress = 769Mb)
>      - pnpm store = 62.958 files/links (1.1Gb) 
> - it won't grow overtime (lock changes affects only a bit). automatically pruned
> - with pnpm there's a lot of chances to reach your cache max budget (more keys on main)
> in other words: cost/benefit balance (refer to ci measurements).
> 
> Also note that pnpm even with cache will still download some archives (nextjs, turbo,...) and seems to be more sensitive to npm outages.
> 
> On CI yarn compress:off will be faster, I tested on high end i7 with 2 cores but the zip compression
> overhead exists on lower end machines


| Command                             |       Mean [s] | Min [s] | Max [s] | Relative |
|:------------------------------------|---------------:|--------:|--------:|---:|
| `yarn cache:on yarn compress:mixed` | 21.300 ± 0.169 |  21.173 |  21.492 | 1.99 ± 0.03 |
| `yarn cache:on yarn compress:off`   | 22.759 ± 0.115 |  22.630 |  22.851 | 2.12 ± 0.03 |
| `pnpm cache:on`                     | 10.712 ± 0.126 |  10.611 |  10.853 | 1.00 |

```bash
# npx -y rimraf@5.0.1 --glob '**/node_modules' .yarn/tmp .pnpm

taskset -c 0,1 hyperfine --runs=3 --export-markdown "docs/bench-pm-with-cache-no-nm.md" --show-output \
\
--command-name "yarn cache:on yarn compress:mixed" \
--prepare "export YARN_CACHE_FOLDER=.yarn/tmp/compress/.cache YARN_COMPRESSION_LEVEL=mixed YARN_LOCKFILE_FILENAME=yarn.mixed-compress.lock YARN_INSTALL_STATE_PATH=.yarn/tmp/compress/install-state.gz && yarn install --immutable && npx -y rimraf@5.0.1 --glob '**/node_modules' .yarn/tmp/compress/install-state.gz" \
"yarn install --immutable" \
\
--command-name "yarn cache:on yarn compress:off" \
--prepare "export YARN_CACHE_FOLDER=.yarn/tmp/no-compress/.cache YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.no-compress.lock YARN_INSTALL_STATE_PATH=.yarn/tmp/no-compress/install-state.gz && yarn install --immutable && npx -y rimraf@5.0.1 --glob '**/node_modules' .yarn/tmp/no-compress/install-state.gz" \
"yarn install --immutable" \
\
--command-name "pnpm cache:on" \
--prepare "npx -y rimraf@5.0.1 --glob '**/node_modules' .pnpm  && pnpm install --virtual-store-dir .pnpm/virtual --store-dir .pnpm/global --frozen-lockfile --prefer-offline && npx -y rimraf@5.0.1 --glob '**/node_modules' .pnpm/virtual" \
"pnpm install --virtual-store-dir .pnpm/virtual --store-dir .pnpm/global --frozen-lockfile --prefer-offline"

# npx -y rimraf@5.0.1 --glob '**/node_modules' .pnpm  .yarn/tmp

```

### Compare yarn options

| Command                                    |       Mean [s] | Min [s] | Max [s] |    Relative |
|:-------------------------------------------|---------------:|--------:|--------:|------------:|
| `yarnCache:on - installState:on - nm:off`  | 21.350 ± 0.216 |  21.185 |  21.595 | 5.59 ± 0.24 |
| `yarnCache:on - installState:off - nm:off` | 22.717 ± 0.225 |  22.510 |  22.957 | 5.95 ± 0.25 |
| `yarnCache:on - installState:off - nm:on`  | 11.676 ± 0.041 |  11.647 |  11.722 | 3.06 ± 0.13 |
| `yarnCache:on - installState:on - nm:on`   |  3.820 ± 0.156 |   3.645 |   3.946 |        1.00 |


```bash
export YARN_CACHE_FOLDER=.yarn/benchmark/cache YARN_COMPRESSION_LEVEL=0 YARN_LOCKFILE_FILENAME=yarn.no-compress.lock;

YARN_INSTALL_STATE_PATH=.yarn/benchmark/install-state.gz yarn install --immutable;

taskset -c 0,1 hyperfine --runs=3 --export-markdown "docs/yarn-bench-various-params.md" \
--command-name "yarnCache:on - installState:on - nm:off" \
--prepare "npx -y rimraf@5.0.1 --glob '**/node_modules'" \
"YARN_INSTALL_STATE_PATH=.yarn/benchmark/install-state.gz yarn install --immutable" \
--command-name "yarnCache:on - installState:off - nm:off" \
--prepare "npx -y rimraf@5.0.1 --glob '**/node_modules' '.yarn/benchmark/install-state.off.gz'" \
"YARN_INSTALL_STATE_PATH=.yarn/benchmark/install-state.off.gz yarn install --immutable" \
--command-name "yarnCache:on - installState:off - nm:on" \
--prepare "npx -y rimraf@5.0.1 --glob '.yarn/benchmark/install-state.off.gz'" \
"YARN_INSTALL_STATE_PATH=.yarn/benchmark/install-state.off.gz yarn install --immutable" \
--command-name "yarnCache:on - installState:on - nm:on" \
--prepare "echo 'all caches'" \
"YARN_INSTALL_STATE_PATH=.yarn/benchmark/install-state.gz yarn install --immutable" \
--show-output
```


```
Summary
  'yarnCache:on - installState:on - nm:on' ran
    3.06 ± 0.13 times faster than 'yarnCache:on - installState:off - nm:off'
    5.59 ± 0.24 times faster than 'yarnCache:on - installState:on - nm:off'
    5.95 ± 0.25 times faster than 'yarnCache:on - installState:off - nm:off'
```

## Running scripts

```bash
export YARN_VERSION="4.0.0-rc.45" PNPM_VERSION="8.6.2"; NPM_VERSION="9.6.1"
export YARN_COMPRESSION_LEVEL=mixed YARN_LOCKFILE_FILENAME=yarn.mixed-compress.lock; 
pnpm i --frozen-lockfile; 
corepack yarn@${YARN_VERSION} install --immutable;
hyperfine --show-output --warmup=1 --runs=20 --export-markdown "docs/calling-npm-script.md" \
"corepack pnpm@${PNPM_VERSION} run echo" \
"corepack yarn@${YARN_VERSION} run echo" \
"corepack npm@${NPM_VERSION} run echo"
```

| Command                              |    Mean [ms] | Min [ms] | Max [ms] |    Relative |
|:-------------------------------------|-------------:|---------:|---------:|------------:|
| `corepack pnpm@8.6.2 run echo`       |  414.6 ± 8.1 |    400.9 |    431.4 | 1.21 ± 0.03 |
| `corepack yarn@4.0.0-rc.45 run echo` | 634.6 ± 24.9 |    613.0 |    712.0 | 1.85 ± 0.08 |
| `corepack npm@9.6.1 run echo`        |  342.9 ± 5.4 |    337.0 |    358.2 |        1.00 |


## Changelog

## Sponsors :heart:

If you are enjoying some this guide in your company, I'd really appreciate a [sponsorship](https://github.com/sponsors/belgattitude), a [coffee](https://ko-fi.com/belgattitude) or a dropped star.
That gives me some more time to improve it to the next level.

