| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `taskset -c 0 npm run install:yarn-mixed-comp:cache` | 46.963 ± 0.938 | 46.052 | 47.926 | 2.46 ± 0.05 |
| `taskset -c 0 npm run install:yarn-no-comp:cache` | 37.743 ± 0.277 | 37.424 | 37.926 | 1.98 ± 0.02 |
| `taskset -c 0 npm run install:pnpm:cache` | 19.085 ± 0.037 | 19.045 | 19.118 | 1.00 |
