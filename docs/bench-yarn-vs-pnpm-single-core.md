| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `taskset -c 0 npm run install:yarn-mixed-comp:cache` | 48.852 ± 1.146 | 47.977 | 50.347 | 1.56 ± 1.24 |
| `taskset -c 0 npm run install:yarn-no-comp:cache` | 38.916 ± 0.170 | 38.707 | 39.075 | 1.24 ± 0.99 |
| `taskset -c 0 npm run install:pnpm:cache` | 31.368 ± 24.988 | 20.147 | 76.067 | 1.00 |
