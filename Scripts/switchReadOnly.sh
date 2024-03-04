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
elif [ "$1" == "rw" ]; then
    NEW_REGISTRY_MODE="false"
else
    echo "Error: Invalid argument. Please specify true or false."
    echo "Usage: $0 <ro|rw>"
    exit 1
fi

# Update registry_mode value in values.yaml
sed -i "s/\(^\s*registry_mode\s*:\s*\).*\$/\1$NEW_REGISTRY_MODE/" "$VALUES_FILE"

echo "Updated registry_mode to $NEW_REGISTRY_MODE in values.yaml"

helm upgrade wso2-is-ha ../wso2-kubecluster-ha-mode --values ../wso2-kubecluster-ha-mode/valuesRO.yaml

