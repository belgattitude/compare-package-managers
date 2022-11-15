| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `taskset -c 0 npm run install:yarn-no-comp` | 39.848 ± 0.937 | 38.671 | 40.832 | 1.95 ± 0.05 |
| `taskset -c 0 npm run install:yarn-mixed-comp` | 50.460 ± 0.811 | 49.210 | 51.417 | 2.47 ± 0.05 |
| `taskset -c 0 pnpm i` | 20.461 ± 0.196 | 20.185 | 20.663 | 1.00 |
