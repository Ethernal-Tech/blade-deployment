#!/bin/bash -e
echo "make version: `make --version`"
echo "jq version: `jq -V`"
echo "forge version: `forge -V`"
echo "cast version: `cast -V`"
echo "golang version: `go version`"
echo "polycli version: `polycli version`"
echo "k6 version: `k6 version`"
set +e
xk6_version=$(xk6 version 2>&1)
set -e
if ( echo "$xk6_version" | grep -q "go.mod file not found" ); then
    echo "xk6 succeeded"
else
    echo "xk6 failed"
fi
xk6_ethereum_output=$(ls /home/ubuntu | grep -w "k6" | wc -l)
if [ $xk6_ethereum_output -eq 1 ]; then
    echo "xk6-ethereum build succeeded";
else
    echo "xk6-ethereum build failed"
fi
echo "npm version: `npm -v`"
echo "yarn version: `yarn --version`"
echo "pandoras-box branch: `cd /opt/pandoras-box && sudo git branch --show-current`"
echo "pandoras-box version: `pandoras-box -V`"
