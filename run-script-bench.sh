#!/bin/sh
# https://github.com/pnpm/pnpm/issues/6447#issuecomment-1518093737

case $1 in
    "npm")
        for i in {1..10}; do npm run echo; done
        ;;
    "yarn")
        for i in {1..10}; do YARN_COMPRESSION_LEVEL=mixed YARN_LOCKFILE_FILENAME=yarn.mixed-compress.lock yarn run echo; done
        ;;
    "pnpm")
        for i in {1..10}; do pnpm run echo; done
        ;;
    *)
        echo "Usage: bench-npm.sh [npm|yarn|pnpm]"
        ;;
esac