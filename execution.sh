#!/bin/bash
echo "Initializing Execution"
IFS=$'\n'; set -f
for f in $(find /tmp/templates -name '*.jsonnet'); do echo "$f"; done
unset IFS; set +f
