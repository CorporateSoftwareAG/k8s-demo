# k8s-demo

## Kubernetes Setup

1. Login to Azure Portal
2. Open a Cloud Shell (Powershell) and run the following Commands:

```PowerShell
#Define parameters
#Leave these parameters
$location = "westeurope"
$resourceGroupName = "k8s-demo-rg"

#Change these names if needed
$acrName = "k8sDemoRegistryNov2021"
$kubernetesName = "k8s-demo-kubernetes-mg"
$servicePrincipalName = "k8s-demo-registry-access-mg"

# Create a resource group
az group create --name $resourceGroupName --location $location
$resourceGroupId = az group show --name $resourceGroupName --query "id" --output tsv

# Create a container registry
az acr create --resource-group $resourceGroupName --name $acrName --sku Basic

# Create a Kubernetes cluster
az aks create --resource-group $resourceGroupName --name $kubernetesName --node-count 1 --enable-addons monitoring --generate-ssh-keys --kubernetes-version 1.20.9

#Attacht the ACR to the Kubernetes Cluster
az aks update -n $kubernetesName -g $resourceGroupName --attach-acr $acrName

# Obtain the full registry ID for subsequent command args
$acrRegistryId = az acr show --name $acrName --resource-group $resourceGroupName --query "id" --output tsv
$acrUrl = az acr show --name $acrName --resource-group $resourceGroupName --query "loginServer" --output tsv

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
$acrAppPassword = az ad sp create-for-rbac --name $servicePrincipalName --scopes $resourceGroupId --role Contributor --query "password" --output tsv
$acrAppUserName = az ad sp list --display-name $servicePrincipalName --query "[].appId" --output tsv
$appTenantId = az ad sp list --display-name $servicePrincipalName --query "[].appOwnerOrganizationId" --output tsv

#Verify Permissions work for the container registry
$acrAppPassword | docker login $acrUrl --username $acrAppUserName --password-stdin

Write-Output "App Tenant Id: $appTenantId"
Write-Output "ACR Registry URL: $acrUrl"
Write-Output "ACR App UserName: $acrAppUserName"
Write-Output "ACR App Password: $acrAppPassword"
```

3. Copy Registry URL, UserName and Password to a NotePad file

4. Go to the Github Repository and open Settings -> Secrets
5. Create new/update repository secrets with the following names and secret values:
* "APP_TENANTID" => add the App Tenant Id you noted before
* "ACR_URL" => add the ACR URL you noted before
* "ACR_APPUSERNAME" => add the ACR App UserName you noted before
* "ACR_APPPASSWORD" => add the ACR App Password you noted before

6. Create a new release in Github, give it a tag and a name in the format of semantic versioning. Example: v0.0.1, v0.0.2 etc.
7. Go to Github Actions in the Repository and wait for the build and deploy workflow to finish
8. Open your Container Registry in the Azure Portal and check the existence of the docker image
9. Open your Kubernetes Cluster and check the existence of the deployed service
10. Click on the public ip of the frontend-service to test the application


