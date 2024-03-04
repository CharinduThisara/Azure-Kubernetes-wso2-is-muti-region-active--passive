#!/bin/bash

# Set the desired value for registry_mode (true or false)
if [ "$1" == "ro" ]; then
    rm -f ../wso2-kubecluster-ha-mode/templates/is_deployment.yaml
    cp ../wso2-kubecluster-ha-mode/deployments/is-node_RO.yaml ../wso2-kubecluster-ha-mode/templates/is_deployment.yaml
    helm upgrade wso2-is-ha ../wso2-kubecluster-ha-mode
elif [ "$1" == "rw" ]; then
    rm -f ../wso2-kubecluster-ha-mode/templates/is_deployment.yaml
    cp ../wso2-kubecluster-ha-mode/deployments/is-node_RW.yaml ../wso2-kubecluster-ha-mode/templates/is_deployment.yaml
    helm upgrade wso2-is-ha ../wso2-kubecluster-ha-mode
else
    echo "Error: Invalid argument. Please specify ro or rw."
    echo "Usage: $0 <ro|rw>"
    exit 1
fi

# Update registry_mode value in values.yaml
# sed -i "s/\(^\s*registry_mode\s*:\s*\).*\$/\1$NEW_REGISTRY_MODE/" "$VALUES_FILE"

echo "Updated registry_mode to $NEW_REGISTRY_MODE in values.yaml"
