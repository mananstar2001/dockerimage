#!/bin/bash
echo "Initializing Execution"
jsonFolder="json"
jsonFile=""
IFS=$'\n'; set -f
for filePath in $(find /tmp/templates -name '*.jsonnet'); do 
	echo "Processing $filePath"
	jsonFile=${filePath/templates/$jsonFolder}
	jsonnet -J /tmp/jsonnet ${filePath} > ${jsonFile}
	echo "done json conversion at ${jsonFile}"
	if[ -f $jsonFile ] 
		echo "${filePath/templates/$jsonFolder} exists"
	done
unset IFS; set +f
