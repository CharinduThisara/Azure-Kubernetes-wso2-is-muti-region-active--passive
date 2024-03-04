#!/bin/bash

# Set the desired value for registry_mode (true or false)
if [ "$1" == "ro" ]; then
    helm upgrade wso2-is-ha ../wso2-kubecluster-ha-mode --values ../wso2-kubecluster-ha-mode/valuesRO.yaml
elif [ "$1" == "rw" ]; then
    helm upgrade wso2-is-ha ../wso2-kubecluster-ha-mode --values ../wso2-kubecluster-ha-mode/values.yaml
else
    echo "Error: Invalid argument. Please specify ro or rw."
    echo "Usage: $0 <ro|rw>"
    exit 1
fi

# Update registry_mode value in values.yaml
# sed -i "s/\(^\s*registry_mode\s*:\s*\).*\$/\1$NEW_REGISTRY_MODE/" "$VALUES_FILE"

echo "Updated registry_mode to $NEW_REGISTRY_MODE in values.yaml"
