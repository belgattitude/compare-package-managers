## Compare package managers

Official benchs from [pnpm](https://pnpm.io/benchmarks) and [yarn 3+](https://yarnpkg.com/benchmarks) aren't
conclusive. Let's test them based on [nextjs-monorepo-example](https://github.com/belgattitude/nextjs-monorepo-example)
for fun and on the CI. Potential for co2 emissions reductions (♻️🌳❤️ ?)

### TLDR;

#### 📥 Install speed 

**± Equivalent** (when yarn compression disabled). Sounds weird ? 
Check the detailed comparison below to know why. See the action in [.github/workflows/ci-install-benchmark.yml](https://github.com/belgattitude/compare-package-managers/blob/main/.github/workflows/ci-install-benchmark.yml)
and the [history log](https://github.com/belgattitude/compare-package-managers/actions/workflows/ci-install-benchmark.yml]).

#### ⏩ Nextjs build speed

Build the nextjs-app example: **Yarn is faster (±2mins vs ±3mins)**. Curious ? See the action in
[.github/workflows/ci-build-benchmark.yml](https://github.com/belgattitude/compare-package-managers/blob/main/.github/workflows/ci-build-benchmark.yml) and
the [history log](https://github.com/belgattitude/compare-package-managers/actions/workflows/ci-build-benchmark.yml)

#### 🔢 Nextjs standalone size

In [standalone mode](https://nextjs.org/docs/advanced-features/output-file-tracing#automatically-copying-traced-files) the **nextjs-app is lighter with PNPM (11MB vs 25MB)**. 
Current [@vercel/nft](https://github.com/vercel/nft) might support pnpm better.
Lower size = faster cold-starts (important when deploying on lambdas). 

See the section "Debug size" in [.github/workflows/ci-build-benchmark.yml](https://github.com/belgattitude/compare-package-managers/blob/main/.github/workflows/ci-build-benchmark.yml) and
the [history log](https://github.com/belgattitude/compare-package-managers/actions/workflows/ci-build-benchmark.yml)

#### 🔢 Install size (in monorepo)

If you're not using nextjs (with standalone mode) things are different. Yarn does a better job at deduping and
also avoid installing native binaries (ie: glibc, musl) thx to [supportedArchitectures](https://yarnpkg.com/configuration/yarnrc#supportedArchitectures).
See also: https://github.com/pnpm/pnpm/issues/5504.

#### 🦺 Safe to use ?

Seems yarn has matured longer from the [peer-dependency chaos](https://gist.github.com/belgattitude/df235dc0ca3929ef2b56eb26fe6f3bed), 
expect less issues than with PNPM. Small binary commited in the repo, no version conflicts (till corepack becomes a reality).
Also to mention a very strict policy about cheksums.... very difficult to abuse. 



### Technicalities

- [Yarn 4.0.0-rc.28](https://yarnpkg.com/) - "Safe, stable, reproducible projects".
- [Pnpm 7.15.0](https://pnpm.io/) - "Fast, disk space efficient package manager".

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
    that gives a 2x boost (and decrease co2 footprint)    
  - Apart from yarn pnp that will be a clear winner, PNPM wins all the time. But be aware that the difference is not that big when you
    handle the cache on the CI.  
    
- Space efficient ? 
  - PNPM claims seems to be based on a scenario in which many versions of the same library co-exists (ie: lodash...). On the example I used, yarn with
    `hardlinks-local` is lighter. This is also due to difference in duplication. Pnpm does not yet provide built-in deduplication (might be less mature
    regarding peer-deps too).

### Scenarios

The following have been tested on CI. Look for the results in the action history:

See results in [actions](https://github.com/belgattitude/compare-package-managers/actions)


### CI: With cache

> Data: 

| CI Scenario             | Install | CI load cache | CI persist cache |  Setup | 
|-------------------------|--------:|--------------:|-----------------:|-------:|
| yarn4 mixed-compression |    ±41s |           ±3s |          *(±6s)* |     0s |
| yarn4 no compression    |    ±33s |           ±4s |          *(±9s)* |     0s |
| pnpm7                   |    ±17s |           ±9s |         *(±16s)* |     1s |

With cache pnpm is the fastest: 27s vs yarn no-compress: 37s. But it's important to mention that 
yarn built-in cache feature allows to almost always start with warm cache (even in case of lock changes).
For example with pnpm when there's a lock change, the 24s becomes 67s + 9s (load cache) +16s (persist cache)
which depending on situations makes yarn wins (63s + 4s + 9s).

Both package managers seems fast though.

<img src="https://user-images.githubusercontent.com/259798/199542234-f828450c-e8e4-4e61-b391-cc022adaa3eb.png" />

### CI: Without cache

> Data: https://github.com/belgattitude/compare-package-managers/actions/runs/3346115309/jobs/5542514593

| CI Scenario              | Install | Setup | 
|--------------------------|--------:|------:|
| yarn4 mixed-compression  |   ±120s |    0s |
| yarn4 no compression     |    ±63s |    0s |
| pnpm7                    |    ±67s |    1s | 

Disabling compression in yarn through [compressionLevel: 0](https://yarnpkg.com/configuration/yarnrc#compressionLevel) makes it twice faster. Makes sense as
the js zip compression brings an overhead on single-core cpu's. Pnpm results are very close, but as it does 
not dedupe as *well* (?) it actually downloads more packages (multiple typescript versions...). Difficult
comparison. 

### CI: action/cache

> First run data: https://github.com/belgattitude/compare-package-managers/actions/runs/3346115309/jobs/5542514593

| CI Scenario              | Retrieve cache | Persist cache |   Size | 
|--------------------------|---------------:|--------------:|-------:|
| yarn4 mixed-compression  |            ±3s |           ±6s |  203MB |
| yarn4 no compression     |            ±4s |           ±9s |  169MB |
| pnpm7                    |            ±8s |          ±16s |  266MB |

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


## Sponsors :heart:

If you are enjoying some this guide in your company, I'd really appreciate a [sponsorship](https://github.com/sponsors/belgattitude), a [coffee](https://ko-fi.com/belgattitude) or a dropped star.
That gives me some more time to improve it to the next level.

