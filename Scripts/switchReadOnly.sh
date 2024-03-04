#!/bin/bash

# Path to values.yaml file
VALUES_FILE="../wso2-kubecluster-ha-mode/values.yaml"

# Check if values.yaml file exists
if [ ! -f "$VALUES_FILE" ]; then
    echo "Error: values.yaml file not found."
    exit 1
fi

# Set the desired value for registry_mode (true or false)
if [ "$1" == "ro" ]; then
    NEW_REGISTRY_MODE="true"
elif [ "$1" == "false" ]; then
    NEW_REGISTRY_MODE="false"
else
    echo "Error: Invalid argument. Please specify true or false."
    exit 1
fi

# Update registry_mode value in values.yaml
sed -i "s/\(^\s*registry_mode\s*:\s*\).*\$/\1$NEW_REGISTRY_MODE/" "$VALUES_FILE"

echo "Updated registry_mode to $NEW_REGISTRY_MODE in values.yaml"

helm upgrade wso2-is-ha . --values ../wso2-kubecluster-ha-mode/values.yaml

