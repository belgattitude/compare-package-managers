## Compare package managers

Benchs from [pnpm](https://pnpm.io/benchmarks) and [yarn 3+](https://yarnpkg.com/benchmarks) already exists.
Let's test the differences based on [nextjs-monorepo-example](https://github.com/belgattitude/nextjs-monorepo-example)
for fun with GH CI first approach (ubuntu). 

Potential for co2 emissions reductions at install, build and runtime (♻️🌳❤️) ?

> See also 2 interesting gists to help you set up caches on github
> - yarn 4 - https://gist.github.com/belgattitude/042f9caf10d029badbde6cf9d43e400a
> - pnpm 8 - https://gist.github.com/belgattitude/838b2eba30c324f1f0033a797bab2e31



#### 📥 Install speed 

Measured through github actions. See [workflows/ci-install-benchmark.yml](./.github/workflows/ci-install-benchmark.yml) and [latest run](https://github.com/belgattitude/compare-package-managers/actions/runs/5050181711/jobs/9060564115)

- PNPM 8.5.1, see [.npmrc](./.npmrc) - best: **39s**  => 23s + 16s (for cache fetch / decompress)
- Yarn 4.0.0-rc.44 / nmLinker, see [.yarnrc.yml](./.yarnrc.yml) - best: **45s** (39s+16s with compressionLevel:0)

**With cache**

| CI Scenario             | Install | CI fetch cache | Total | Cache size | CI persist cache |
|-------------------------|--------:|---------------:|------:|-----------:|-----------------:|
| yarn4 mixed-compression |    ±51s |            ±4s |   **55s** |      201Mb |          *(±5s)* |
| yarn4 no compression    |    ±39s |            ±6s |   **45s** |      155Mb |          *(±8s)* |
| pnpm8.5.1               |    ±23s |           ±16s |   **39s** |      253Mb |         *(±30s)* |

**Without cache**

| CI Scenario                        | Install | Diff with cached run | 
|------------------------------------|--------:|---------------------:|
| yarn4 mixed-compression / no cache |   ±110s |      slower than 55s |
| yarn4 no compression / no cache    |    ±63s |      slower than 45s |
| pnpm8 / no cache                   |    ±80s |      slower than 39s | 


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

Build the nextjs-app [standalone mode](https://nextjs.org/docs/advanced-features/output-file-tracing#automatically-copying-traced-files): **Yarn / Pnpm are euqivalent (+/- 1min)**. Curious ? See the action in
[.github/workflows/ci-build-benchmark.yml](https://github.com/belgattitude/compare-package-managers/blob/main/.github/workflows/ci-build-benchmark.yml) and
the [history log](https://github.com/belgattitude/compare-package-managers/actions/workflows/ci-build-benchmark.yml)

That said I couldn't reliably make prisma works with pnpm (without `auto-install-peers=true` which increase the deps a lot), 
neither nextjs with standalone mode.

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
- [Pnpm 8.5.1](https://pnpm.io/) - "Fast, disk space efficient package manager".

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
  - PNPM handles peer-deps differently. In some aspects it's more solid than yarn with node_modules
    but it does not dedupe them (leading to more versions installed). 
  - Yarn offers `supportedArchitectures`. When configured to current, it helps to not download native binaries for
    other platforms (ie: amd64 + musl for esbuild, swc...)

### Scenarios

The following have been tested on CI. Look for the results in the action history:

See results in [actions](https://github.com/belgattitude/compare-package-managers/actions)


### CI: With cache

> Example from a recent run

| CI Scenario             | Install | CI fetch cache | CI persist cache | Setup | 
|-------------------------|--------:|---------------:|-----------------:|------:|
| yarn4 mixed-compression |    ±42s |            ±3s |          *(±6s)* |    0s |
| yarn4 no compression    |    ±34s |            ±4s |          *(±9s)* |    0s |
| pnpm8                   |    ±19s |            ±8s |         *(±16s)* |    2s |


The CI fetch cache (time taken for the github action to load and extract the cache archive) 
differences happens can be explained by:

- PNPM dedupe differently that explains the difference in sizes (see below).
- YARN with supportedArchitectures: current does not download extra binaries (ie: linux+musl)
- When yarn use mixed-compression the internal github zstd don't compress the yarn zip archives.   


Thus: pnpm (19+8+2) = 29s vs yarn no-comp (34+4+0) = 38s.

https://github.com/belgattitude/compare-package-managers/actions/runs/4565624343/jobs/8057000146

![image](https://user-images.githubusercontent.com/259798/228883737-9d79ee5d-2130-4db3-a38d-522b57cb2f91.png)



Important to mention though

- on yarn.lock changes only yarn is able to start with the cache (download differences only and persist).
- ci persist cache only happens on yarn.lock changes, for example

<img src="https://user-images.githubusercontent.com/259798/199542234-f828450c-e8e4-4e61-b391-cc022adaa3eb.png" />

### CI: Without cache

> Data: https://github.com/belgattitude/compare-package-managers/actions/runs/3346115309/jobs/5542514593

| CI Scenario              | Install | Setup | 
|--------------------------|--------:|------:|
| yarn4 mixed-compression  |   ±140s |    0s |
| yarn4 no compression     |    ±54s |    0s |
| pnpm7                    |    ±50s |    1s | 

Disabling compression in yarn through [compressionLevel: 0](https://yarnpkg.com/configuration/yarnrc#compressionLevel) makes it twice faster. Makes sense as
the js zip compression brings an overhead on single-core cpu's. Pnpm results are very close, but as it does 
not dedupe as *well* (?) it actually downloads more packages (multiple typescript versions...). Difficult
comparison. Confirmed by gdu and action cache:

![image](https://user-images.githubusercontent.com/259798/213884689-3e550c69-0ca2-4551-b383-c99ebcbbbf8e.png)

### CI: action/cache

> First run data: https://github.com/belgattitude/compare-package-managers/actions/runs/3346115309/jobs/5542514593

**Warning** the fetch/persist times varies a lot between runs.

| CI Scenario             | Fetch cache | Persist cache |  Size | 
|-------------------------|------------:|--------------:|------:|
| yarn4 mixed-compression |         ±5s |           ±5s | 201MB |
| yarn4 no compression    |         ±8s |           ±8s | 155MB |
| pnpm8                   |        ±14s |          ±30s | 253MB |

When already compressed the yarn cache is stored faster in the github cache. Make sense as action/cache won't 
try to compress something already compressed. On the pnpm side saving the pnpm-store is much slower, this is due
to different deduplication but also to the fact that it has to compress more files (+symlinks...). Note also
that regarding cache yarn has an advantage: it does not need to be recreated for different os/architectures. 

<details>
  <summary>Give me a screenshot of cache retrieval</summary>
  <img src="https://user-images.githubusercontent.com/259798/199530263-c443171b-0d47-4937-ab4b-a0382d4200f2.png" /> 
</details>

<details>
  <summary>Give me a screenshot of cache restoration</summary>
  <img src="https://user-images.githubusercontent.com/259798/199531335-34584af8-366e-477d-bc50-8016c734ad48.png" /> 
</details>


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


## Changelog

## Sponsors :heart:

If you are enjoying some this guide in your company, I'd really appreciate a [sponsorship](https://github.com/sponsors/belgattitude), a [coffee](https://ko-fi.com/belgattitude) or a dropped star.
That gives me some more time to improve it to the next level.

