#!/bin/bash

# Path to values.yaml file
VALUES_FILE="../wso2-kubecluster-ha-mode/values.yaml"

# Check if values.yaml file exists
if [ ! -f "$VALUES_FILE" ]; then
    echo "Error: values.yaml file not found."
    exit 1
fi

# Set the desired value for registry_mode (true or false)
NEW_REGISTRY_MODE="true"

# Update registry_mode value in values.yaml
sed -i "s/\(^\s*registry_mode\s*:\s*\).*\$/\1$NEW_REGISTRY_MODE/" "$VALUES_FILE"

echo "Updated registry_mode to $NEW_REGISTRY_MODE in values.yaml"

helm upgrade wso2-is-ha . --values ./values.yaml --recreate-pods

