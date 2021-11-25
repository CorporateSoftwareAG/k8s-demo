# k8s-demo

## Kubernetes Setup

1. Login to Azure Portal
2. Open a Cloud Shell (Powershell) and run the following Commands:

```PowerShell
#Define parameters
$location = "westeurope"
$resourceGroupName = "k8s-demo-rg"
$acrName = "k8sDemoRegistryNov2021"
$kubernetesName = "k8s-demo-kubernetes"
$servicePrincipalName = "k8s-demo-registry-access"

# Create a resource group
az group create --name $resourceGroupName --location $location

# Create a container registry
az acr create --resource-group $resourceGroupName --name $acrName --sku Basic

# Create a Kubernetes cluster
az aks create --resource-group $resourceGroupName --name $kubernetesName --node-count 1 --enable-addons monitoring --generate-ssh-keys --kubernetes-version 1.20.9

# Obtain the full registry ID for subsequent command args
$acrRegistryId = az acr show --name $acrName --query "id" --output tsv
$acrUrl = az acr show --name $acrName --query "loginServer" --output tsv

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
$acrAppPassword = az ad sp create-for-rbac --name $servicePrincipalName --scopes $acrRegistryId --role acrpush --query "password" --output tsv
$acrAppUserName = az ad sp list --display-name $servicePrincipalName --query "[].appId" --output tsv

#Verify Permissions work for the container registry
echo $acrAppPassword | docker login $acrUrl --username $acrAppUserName --password-stdin

Write-Output "ACR Registry URL: $acrUrl"
Write-Output "ACR App UserName: $acrAppUserName"
Write-Output "ACR App Password: $acrAppPassword"
```

3. Copy Registry URL, UserName and Password to a NotePad file
4. Clone the current repository to your disk using Powershell and the following command:
```PowerShell
git clone https://github.com/CorporateSoftwareAG/k8s-demo.git
```
5. Open the file .github\workflows\build-and-push-docker.yml
6. Update the environment variables "ACR_URL" and "ACR_APPID" with the ACR Registry URL and ACR App UserName you noted before
7. Go to the Github Repository and open Settings -> Secrets
8. Create a new/update the repository secret with the name "ACR_APPPASSWORD", and add the ACR App Password you noted before
9. Open a Powershell in your Git Folder and run:

```PowerShell
git add *
git commit -m "Updated ACR Info"
git push
```



