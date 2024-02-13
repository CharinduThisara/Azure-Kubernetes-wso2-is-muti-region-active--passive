# Deploying WSO2 Identity Server in Active/Passive with Hot Standby Mode on Azure

This guide will walk you through the process of setting up Azure Kubernetes Service (AKS), databases, and deploying the WSO2 Identity Server in an Active/Passive configuration with Hot Standby Mode in Azure.

## Prerequisites

Before proceeding, ensure you have the following:

- An Azure subscription.
- WSO2 Identity Server package.
- Docker installed on your local machine.

## Walk-through

### Step 1: Create Resource Groups

1. Create two Resource Groups under your Azure Subscription in paired regions (e.g., East-US 2 and Central-US).

### Step 2: Create Azure Container Registry (ACR)

1. Create an Azure Container Registry (ACR). If your organization already has ACRs, use them.

### Step 3: Build and Push Docker Image

1. Build a Docker image of the Identity Server and push it to the Azure Container Registry (ACR).

### Step 4: Create Azure Kubernetes Service (AKS)

1. Create a private Azure Kubernetes Service (AKS) for the primary (Active) instance of the Identity Server.

### Step 5: Set Up Linux VM

1. Create a Linux VM in Azure and connect it to the AKS.
2. Install kubectl, Helm, and Azure CLI on the VM.

### Step 6: Create Helm Package

1. Create a Helm package for the IS Kubernetes Deployment and push it to Git.

### Step 7: Clone Git Repo to VM

1. Clone the Git repository to the VM.

### Step 8: Deploy WSO2 Identity Server

1. Deploy the IS Cluster with the default h2 database and verify accessibility.

### Step 9: Repeat Steps 3-8 for Secondary Region

1. Repeat Steps 3-8 in the paired region (Central-US) to deploy the secondary instance of the Identity Server.

### Step 10: Connect External Database

1. Create two SQL Servers in each paired region.
2. Create a database in the primary region and set up Geo-Replication for read-only replica.
3. Delete previous Identity Server deployments and edit configurations to use the external database:
   - Use volume mount to replace `deployment.toml` for database configurations.
   - Use volume mount to replace `registry.xml.j2` to enable read-only mode for the IS in the secondary region.

By following these steps, you will have successfully deployed the WSO2 Identity Server in an Active/Passive configuration with Hot Standby Mode on Azure.
