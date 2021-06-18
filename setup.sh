#!/bin/bash

### TODO - remove this after adding to readme fences

set -e

# teamName is required
if [ -z "$1" ]
then
  echo Usage: ./airs-setup.sh teamName
  exit 1
fi

# help
if [ "-h" == "$1" ] || [ "--help" == "$1" ]
then
  echo Usage: ./airs-setup.sh teamName
  exit 0
fi

# check Azure login
if [ -z $(az ad signed-in-user show --query objectId -o tsv) ]
then
  echo Login to Azure first
  exit 1
fi

# check certs
if [ -z "$APP_GW_CERT" ]
then
  echo App Gateway SSL certificate is missing
  exit 1
fi

if [ -z "$INGRESS_CERT" ]
then
  echo Ingress SSL certificate is missing
  exit 1
fi

if [ -z "$INGRESS_KEY" ]
then
  echo Ingress SSL private key is missing
  exit 1
fi

# change to this directory
cd $(dirname $0)

# save param as ASB_TEAM_NAME
export ASB_TEAM_NAME=$1

# set default location
if [ -z "$ASB_LOCATION" ]
then
  export ASB_LOCATION=eastus2
fi

# set default geo redundant location for ACR
if [ -z "$ASB_GEO_LOCATION" ]
then
  export ASB_GEO_LOCATION=centralus
fi

# make sure the locations are different
if [ "$ASB_LOCATION" == "$ASB_GEO_LOCATION" ]
then
  echo ASB_LOCATION and ASB_GEO_LOCATION must be different regions
  echo Using paired regions is recommended
  exit 1
fi

# AAD admin group name
if [ -z "$ASB_CLUSTER_ADMIN_GROUP" ]
then
  echo ASB_CLUSTER_ADMIN_GROUP must be set to an existing group name
  exit 1
fi

# get AAD cluster admin group
export ASB_CLUSTER_ADMIN_ID=$(az ad group show -g $ASB_CLUSTER_ADMIN_GROUP --query objectId -o tsv)

if [ -z "$ASB_CLUSTER_ADMIN_ID" ]
then
  echo "Unable to find Cluster Admin Group $ASB_CLUSTER_ADMIN_GROUP"
  exit 1
fi

export ASB_GIT_REPO=$(git remote -v | cut -f 2 | cut -f 1 -d " " | head -n 1)

if [ -z "$ASB_GIT_REPO" ]
then
  echo Please cd to an ASB git repo
  exit 1
fi

export ASB_GIT_PATH=gitops
export ASB_GIT_BRANCH=$(git status  --porcelain --branch | head -n 1 | cut -f 2 -d " " | cut -f 1 -d .)

# don't allow main branch
if [ -z "$ASB_GIT_BRANCH" ] || [ "main" == "$ASB_GIT_BRANCH" ]
then
  echo Please create a branch for this cluster
  echo See readme for instructions
  exit 1
fi

# set default domain name
export ASB_DNS_ZONE=aks-sb.com
export ASB_DOMAIN=${ASB_TEAM_NAME}.${ASB_DNS_ZONE}

# resource group names
export ASB_RG_CORE=rg-${ASB_TEAM_NAME}-core
export ASB_RG_HUB=rg-${ASB_TEAM_NAME}-networking-hub
export ASB_RG_SPOKE=rg-${ASB_TEAM_NAME}-networking-spoke

# export AAD env vars
export ASB_TENANT_ID=$(az account show --query tenantId -o tsv)

# save env vars
./saveenv.sh -y

# create the resource groups
az group create -n $ASB_RG_HUB -l $ASB_LOCATION
az group create -n $ASB_RG_SPOKE -l $ASB_LOCATION
az group create -n $ASB_RG_CORE -l $ASB_LOCATION

# deploy the network
az deployment group create -g $ASB_RG_HUB -f networking/hub-default.json -p location=${ASB_LOCATION}
export ASB_VNET_HUB_ID=$(az deployment group show -g $ASB_RG_HUB -n hub-default --query properties.outputs.hubVnetId.value -o tsv)

az deployment group create -g $ASB_RG_SPOKE -f networking/spoke-BU0001A0008.json -p location=${ASB_LOCATION} hubVnetResourceId="${ASB_VNET_HUB_ID}"
export ASB_NODEPOOLS_SUBNET_ID=$(az deployment group show -g $ASB_RG_SPOKE -n spoke-BU0001A0008 --query properties.outputs.nodepoolSubnetResourceIds.value -o tsv)

az deployment group create -g $ASB_RG_HUB -f networking/hub-regionA.json -p location=${ASB_LOCATION} nodepoolSubnetResourceIds="['${ASB_NODEPOOLS_SUBNET_ID}']"
export ASB_SPOKE_VNET_ID=$(az deployment group show -g $ASB_RG_SPOKE -n spoke-BU0001A0008 --query properties.outputs.clusterVnetResourceId.value -o tsv)

# create AKS
az deployment group create -g $ASB_RG_CORE \
  -f cluster-stamp.json \
  -n cluster-${ASB_TEAM_NAME} \
  -p location=${ASB_LOCATION} \
     geoRedundancyLocation=${ASB_GEO_LOCATION} \
     asbTeamName=${ASB_TEAM_NAME} \
     asbDomain=${ASB_DOMAIN} \
     asbDnsZone=${ASB_DNS_ZONE} \
     targetVnetResourceId=${ASB_SPOKE_VNET_ID} \
     clusterAdminAadGroupObjectId=${ASB_CLUSTER_ADMIN_ID} \
     k8sControlPlaneAuthorizationTenantId=${ASB_TENANT_ID} \
     appGatewayListenerCertificate=${APP_GW_CERT} \
     aksIngressControllerCertificate="$(echo $INGRESS_CERT | base64 -d)" \
     aksIngressControllerKey="$(echo $INGRESS_KEY | base64 -d)"

# get the name of the deployment key vault
export ASB_KV_NAME=$(az deployment group show -g $ASB_RG_CORE -n cluster-${ASB_TEAM_NAME} --query properties.outputs.keyVaultName.value -o tsv)

# get cluster name
export ASB_AKS_NAME=$(az deployment group show -g $ASB_RG_CORE -n cluster-${ASB_TEAM_NAME} --query properties.outputs.aksClusterName.value -o tsv)

# Get the public IP of our App gateway
export ASB_AKS_PIP=$(az network public-ip show -g $ASB_RG_SPOKE --name pip-BU0001A0008-00 --query ipAddress -o tsv)

# Get the AKS Ingress Controller Managed Identity details.
export ASB_TRAEFIK_RESOURCE_ID=$(az deployment group show -g $ASB_RG_CORE -n cluster-${ASB_TEAM_NAME} --query properties.outputs.aksIngressControllerPodManagedIdentityResourceId.value -o tsv)
export ASB_TRAEFIK_CLIENT_ID=$(az deployment group show -g $ASB_RG_CORE -n cluster-${ASB_TEAM_NAME} --query properties.outputs.aksIngressControllerPodManagedIdentityClientId.value -o tsv)
export ASB_POD_MI_ID=$(az identity show -n podmi-ingress-controller -g $ASB_RG_CORE --query principalId -o tsv)

# config traefik
export ASB_INGRESS_CERT_NAME=appgw-ingress-internal-aks-ingress-tls
export ASB_INGRESS_KEY_NAME=appgw-ingress-internal-aks-ingress-key

# save env vars
./saveenv.sh -y

rm -f gitops/ingress/02-traefik-config.yaml
cat templates/traefik-config.yaml | envsubst > gitops/ingress/02-traefik-config.yaml
rm -f gitops/ngsa/ngsa-ingress.yaml
cat templates/ngsa-ingress.yaml | envsubst > gitops/ngsa/ngsa-ingress.yaml

# update flux.yaml
rm -f flux.yaml
cat templates/flux.yaml | envsubst  > flux.yaml

# get AKS credentials
az aks get-credentials -g $ASB_RG_CORE -n $ASB_AKS_NAME

# rename context for simplicity
kubectl config rename-context $ASB_AKS_NAME $ASB_TEAM_NAME

echo "add DNS A record - $ASB_TEAM_NAME  $ASB_AKS_PIP"
