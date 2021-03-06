#Connexion à la souscription Azure
az login
az account list
az account set --subscription "id-souscription"

# general
$location = "francecentral"
$aksrg = "rg-aks"

# Nom du cluster AKS
$aks = "clusterAKS"

# Nom de l'Azure Container Registry
$registry = "registryACRDemo"

# Création du groupe de ressource
az group create --name $aksrg --location $location

# Création de la registry
az acr create --name $registry --resource-group $aksrg --sku basic

# Id de la registry
$registryId=$(az acr show --name $registry --resource-group $aksrg --query "id" --output tsv)

# Création du cluster AKS avec zone de disponibilité
az aks create --name $aks --resource-group $aksrg --attach-acr $registryId --generate-ssh-keys --vm-set-type VirtualMachineScaleSets --load-balancer-sku standard --node-count 3 --zones 1 2 3
    
# Récupération de l'id du cluster AKS
$aks_resourceId = $(az aks show -n $aks -g $aksrg --query id -o tsv)

# En attente du déploiement
az resource wait --exists --ids $aks_resourceId

# Connexion au cluster AKS
az aks get-credentials --resource-group $aksrg --name $aks  --overwrite-existing

# Récupération des infos du cluster
kubectl cluster-info
