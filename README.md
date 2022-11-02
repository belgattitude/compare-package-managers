## Compare package managers

There's few official benchmarks provided by [pnpm](https://pnpm.io/benchmarks) and [yarn 3+](https://yarnpkg.com/benchmarks) about their speed. 
Was curious how they compare to a real-world scenario based off [nextjs-monorepo-example](https://github.com/belgattitude/nextjs-monorepo-example).
Install is the most common operation in ci, local, docker... potential for co2 emissions reductions (?)

### Technicalities

- [Yarn 4.0.0-rc.27](https://yarnpkg.com/) - "Safe, stable, reproducible projects".
- [Pnpm 7.14.1](https://pnpm.io/) - "Fast, disk space efficient package manager".

Official NPM is not currently included to the comparison as it would require some work to support some features 
used in the example monorepo (ie: workspace protocol...). Feel free to open a PR.  

Yarn support 3 module resolution algorithms (often called hoisting): node_modules, pnp and pnpm (alpha). Only the
`nodeLinker: node-modules` have been included in this test to prevent any compatibility issues. 
Keep in mind that the pnp linker will be the fastest in install and will even bring speedups at runtime.

Pnpm is a fast moving package manager recently endorsed by vercel. 

### TLDR;

- Reproducible ? 
  - Yarn lightweight js binary is committed within the repo (<3mb). That avoid bugs due to
    difference in versions. In that regard pnpm lags a behind (>40mb per os/arch). The experimental [corepack](https://nodejs.org/api/corepack.html)
    will bring solution to this. Both package managers already support corepack, but there's some time before a stable ecosystem shift.
  - Yarn is very picky about strictness, checksums... it's quite difficult to abuse. Something that is generally preferred in the enterprise world. 
- Fast ? 
  - On CI what makes the biggest different is to set up a cache. Simple and easy. 
    See [pnpm cache gist](https://gist.github.com/belgattitude/838b2eba30c324f1f0033a797bab2e31) and [yarn cache gist](https://gist.github.com/belgattitude/042f9caf10d029badbde6cf9d43e400a),
    that gives a 2x boost (and decrease co2 footprint)    
  - Apart from yarn pnp that will be a clear winner, PNPM wins all the time. But be aware that the difference is not that big when you
    put add the cache.  
    
- Space efficient ? 
  - PNPM claims seems to be based on a scenario in which many versions of the same library co-exists (ie: lodash...). On the example I used, yarn with
    `hardlinks-local` is lighter. This is also due to difference in duplication. Pnpm does not yet provide built-in deduplication (might be less mature
    regarding peer-deps too).

### Scenarios

The foll

### CI: With cache

> Data: 

| CI Scenario             | Install | @action/cache |   Setup | Total        | Projection    | Save/mo    | Save/mo |
|-------------------------|--------:|--------------:|--------:|-------------:|-----------------:|-------------------:|-----------------:|
| yarn4 mixed-compression |    ±69s |               |      0s | ±113s      | ±12.5h/mo |                        | *reference*    |
| yarn4 no compression    |    ±39s |    *no-cache* |      0s | ±113s      | ±12.5h/mo |                        | *reference*    |
| pnpm7                   |    ±59s |    *no-cache* |      0s | ±113s      | ±12.5h/mo |                        | *reference*    |


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

### CI: Saving cache

> Data: https://github.com/belgattitude/compare-package-managers/actions/runs/3346115309/jobs/5542514593

| CI Scenario              | Install |   Size | 
|--------------------------|--------:|-------:|
| yarn4 mixed-compression  |     ±6s |  203MB |
| yarn4 no compression     |     ±9s |  169MB |
| pnpm7                    |    ±16s |  266MB |

When already compressed the yarn cache is stored faster in the github cache. Make sense as action/cache won't 
try to compress something already compressed. On the pnpm side saving the pnpm-store is much slower, this is due
to different deduplication but also to the fact that it has to compress more files (+symlinks...). Note also
that regarding cache yarn has an advantage: it does not need to be recreated for different os/architectures. 


## Sponsors :heart:

If you are enjoying some this guide in your company, I'd really appreciate a [sponsorship](https://github.com/sponsors/belgattitude), a [coffee](https://ko-fi.com/belgattitude) or a dropped star.
That gives me some more time to improve it to the next level.

