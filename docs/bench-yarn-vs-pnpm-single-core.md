| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `taskset -c 0 npm run install:yarn-no-comp` | 39.219 ± 0.323 | 38.683 | 39.546 | 1.98 ± 0.02 |
| `taskset -c 0 pnpm i` | 19.850 ± 0.079 | 19.767 | 19.955 | 1.00 |
| `taskset -c 0 npm run install:yarn-mixed-comp` | 48.605 ± 0.818 | 47.611 | 49.715 | 2.45 ± 0.04 |
