#!/bin/bash
echo "Initializing Execution"
jsonFolder="json"
IFS=$'\n'; set -f
for filePath in $(find /tmp/templates -name '*.jsonnet'); do echo "$filePath"; jsonnet -J /tmp/jsonnet "$filePath"> "${filePath/templates/$jsonFolder}"; echo "done json conversion at ${filePath/templates/$jsonFolder}"; if[ -f ${filePath/templates/$jsonFolder} ]; echo "${filePath/templates/$jsonFolder} exists"; done
unset IFS; set +f
