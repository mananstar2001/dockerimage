#!/bin/bash
echo "Initializing Execution"
json="json"
jsonFile=""
IFS=$'\n'; set -f
for filePath in $(find /tmp/templates -name '*.jsonnet'); do 
	echo "Processing $filePath"
	jsonFile=${${filePath/templates/$v}/jsonnet/$json}
	echo "jsonFile $jsonFile"
	mkdir -p "$(dirname "$jsonFile")" && touch "$jsonFile"
	jsonnet -J /tmp/jsonnet "${filePath}" > "${jsonFile}"
	echo "done json conversion at ${jsonFile}"
	if [ -f "$jsonFile" ] ; then
		echo "${filePath/templates/$jsonFolder} exists"
	fi
done
unset IFS; set +f
