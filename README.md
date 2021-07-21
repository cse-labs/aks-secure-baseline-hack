# AKS Secure Baseline OpenHack

> Welcome to the Patterns and Practices (PnP) AKS Secure Baseline (ASB) OpenHack!

- The Patterns and Practices AKS Secure Baseline repo is located [here](https://github.com/mspnp/aks-secure-baseline)
  - This repo is a summarization specifically for the OpenHack and `should not be used for production deployments`
  - Please refer to the PnP repo as the `upstream repo`

## Filing Bugs

> Please capture any bugs, issues or ideas on the `GitHub Board`

## Deploying ASB

> Make sure you accepted your GitHub invitation to the org BEFORE creating your Codespace!

### Create Codespace

> The OpenHack requires Codespaces and bash
> If you have dotfiles that default to zsh, make sure to use bash as your terminal

- The `AKS Secure Baseline` repo for the OpenHack is at [github//asb-spark/openhack](https://github.com/asb-spark/openhack)
- Open this repo in your web browser
- Create a new `Codespace` in this repo
  - If the `fork option` appears, you need to request permission to the repo
  - Do not choose fork

🛑 Do not ignore an error as your deploy will fail in about an hour

- the likely problem is you didn't accept your invite to the organization
- close this Codespace, accept your invite and start over

```bash

# check certs
if [ -z $APP_GW_CERT ]; then echo "App Gateway cert not set correctly"; fi
if [ -z $INGRESS_CERT ]; then echo "Ingress cert not set correctly"; fi
if [ -z $INGRESS_KEY ]; then echo "Ingress key not set correctly"; fi

```

```bash

🛑 Run these commands one at a time

# login to your Azure subscription
az login

# verify the correct subscription
# use az account set -s <sub> to change the sub if required
# you must be the owner of the subscription
# tenant ID should be 72f988bf-86f1-41af-91ab-2d7cd011db47 
az account show -o table

```

### Verify the security group

```bash

# set your security group name
export ASB_CLUSTER_ADMIN_GROUP=asb-hack

# verify you are a member of the security group
# if you are not a member, please make sure you filled out the Office Form and IM bartr directly
az ad group member list -g $ASB_CLUSTER_ADMIN_GROUP  --query [].mailNickname -o table | grep <youralias>

```

### Set Team Name

> Team Name is used in resource naming to provide unique names for the OpenHack

- Team Name is very particular and won't fail for about an hour ...
  - we recommend youralias1 (not first.last)
    - if your alias > 7 chars, you need to trim it to total length of 8 or less
  - must be lowercase
  - must start with a-z
  - must only be a-z or 0-9
  - max length is 8
  - min length is 3

```bash

🛑 Set your Team Name per the above rules

#### set the team name
export ASB_TEAM_NAME=[starts with a-z, [a-z,0-9], max length 8]

```

```bash

# make sure the resource group doesn't exist
az group list -o table | grep $ASB_TEAM_NAME

# make sure the branch doesn't exist
git branch -a | grep $ASB_TEAM_NAME

# if either exists, choose a different team name and try again

```

### Create git branch

> Do not PR a `cluster branch` into main
>
> The cluster branch name must be the same as the Team name

```bash

# create a branch for your cluster
# Do not change the branch name from $ASB_TEAM_NAME
git checkout -b $ASB_TEAM_NAME
git push -u origin $ASB_TEAM_NAME

```

### Choose your deployment region

```bash

🛑 Only choose one pair from the below block

### choose the closest pair - not all regions support ASB
export ASB_LOCATION=eastus2
export ASB_GEO_LOCATION=centralus

export ASB_LOCATION=centralus
export ASB_GEO_LOCATION=eastus2

export ASB_LOCATION=westus2
export ASB_GEO_LOCATION=westcentralus

export ASB_LOCATION=northeurope
export ASB_GEO_LOCATION=westeurope

export ASB_LOCATION=australiaeast
export ASB_GEO_LOCATION=australiasoutheast

export ASB_LOCATION=japaneast
export ASB_GEO_LOCATION=japanwest

export ASB_LOCATION=southeastasia
export ASB_GEO_LOCATION=eastasia

export ASB_LOCATION=eastus2
export ASB_GEO_LOCATION=centralus

```

### Save your work in-progress

```bash

# install kubectl and kubelogin
sudo az aks install-cli

# run the saveenv.sh script at any time to save ASB_* variables to ASB_TEAM_NAME.asb.env
./saveenv.sh -y

# if your terminal environment gets cleared, you can source the file to reload the environment variables
# source ${ASB_TEAM_NAME}.asb.env

```

### Setup AKS Secure Baseline

> Complete setup takes about an hour

#### Validate env vars

```bash

# validate team name is set up
echo $ASB_TEAM_NAME

# verify the correct subscription
az account show -o table

# check certs
if [ -z $APP_GW_CERT ]; then echo "App Gateway cert not set correctly"; fi
if [ -z $INGRESS_CERT ]; then echo "Ingress cert not set correctly"; fi
if [ -z $INGRESS_KEY ]; then echo "Ingress key not set correctly"; fi

```

#### AAD

```bash

# get AAD cluster admin group
export ASB_CLUSTER_ADMIN_ID=$(az ad group show -g $ASB_CLUSTER_ADMIN_GROUP --query objectId -o tsv)

# verify AAD admin group
echo $ASB_CLUSTER_ADMIN_GROUP
echo $ASB_CLUSTER_ADMIN_ID

```

#### Set variables for deployment

```bash

# set GitOps repo
export ASB_GIT_REPO=$(git remote get-url origin)
export ASB_GIT_BRANCH=$ASB_TEAM_NAME
export ASB_GIT_PATH=gitops

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

```

### Azure Policies

If you have additional Azure Policies on your subscription, it could cause deployment to fail. If that happens, check your policies and disable anything that is blocking.

Ask the coaches for help debugging.

#### Create Resource Groups

```bash

# create the resource groups
az group create -n $ASB_RG_HUB -l $ASB_LOCATION
az group create -n $ASB_RG_SPOKE -l $ASB_LOCATION
az group create -n $ASB_RG_CORE -l $ASB_LOCATION

```

#### Setup Network

```bash

# this section takes 15-20 minutes to complete

# create hub network
az deployment group create -g $ASB_RG_HUB -f networking/hub-default.json -p location=${ASB_LOCATION} --query name
export ASB_VNET_HUB_ID=$(az deployment group show -g $ASB_RG_HUB -n hub-default --query properties.outputs.hubVnetId.value -o tsv)

# create spoke network
az deployment group create -g $ASB_RG_SPOKE -f networking/spoke-BU0001A0008.json -p location=${ASB_LOCATION} hubVnetResourceId="${ASB_VNET_HUB_ID}" --query name
export ASB_NODEPOOLS_SUBNET_ID=$(az deployment group show -g $ASB_RG_SPOKE -n spoke-BU0001A0008 --query properties.outputs.nodepoolSubnetResourceIds.value -o tsv)

# create Region A hub network
az deployment group create -g $ASB_RG_HUB -f networking/hub-regionA.json -p location=${ASB_LOCATION} nodepoolSubnetResourceIds="['${ASB_NODEPOOLS_SUBNET_ID}']" --query name
export ASB_SPOKE_VNET_ID=$(az deployment group show -g $ASB_RG_SPOKE -n spoke-BU0001A0008 --query properties.outputs.clusterVnetResourceId.value -o tsv)

./saveenv.sh -y

```

#### Setup AKS

```bash

### this section takes 15-20 minutes

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
     aksIngressControllerKey="$(echo $INGRESS_KEY | base64 -d)" \
     --query name

```

#### Set AKS env vars

```bash

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

./saveenv.sh -y

```

### Create setup files

```bash

# traefik config
rm -f gitops/ingress/02-traefik-config.yaml
cat templates/traefik-config.yaml | envsubst > gitops/ingress/02-traefik-config.yaml

# app ingress
rm -f gitops/ngsa/ngsa-ingress.yaml
cat templates/ngsa-ingress.yaml | envsubst > gitops/ngsa/ngsa-ingress.yaml

# GitOps (flux)
rm -f flux.yaml
cat templates/flux.yaml | envsubst  > flux.yaml

```

### Push to GitHub

> The setup process creates 4 new files
>
> GitOps will not work unless these files are merged into your branch

```bash

# check deltas - there should be 4 new files
git status

# push to your branch
git add .
git commit -m "added cluster config"
git push

```

### AKS Validation

```bash

# get AKS credentials
az aks get-credentials -g $ASB_RG_CORE -n $ASB_AKS_NAME

# rename context for simplicity
kubectl config rename-context $ASB_AKS_NAME $ASB_TEAM_NAME

# check the nodes
# requires Azure login
kubectl get nodes

# check the pods
kubectl get pods -A

### Congratulations!  Your AKS Secure Baseline cluster is running!

```

### Deploy Flux

> ASB uses `Flux CD` for `GitOps`

```bash

# setup flux
kubectl apply -f flux.yaml

# 🛑 check the pods until everything is running
kubectl get pods -n flux-cd -l app.kubernetes.io/name=flux

# check flux logs
kubectl logs -n flux-cd -l app.kubernetes.io/name=flux

```

### Validate Ingress

> ASB uses `Traefik` for ingress

```bash

# wait for traefik pods to start
### this can take 2-3 minutes
kubectl get pods -n ingress

## Verify with curl
### this can take 1-2 minutes
### if you get a 502 error retry until you get 200

# test https
curl https://${ASB_DOMAIN}/memory/version

### Congratulations! You have GitOps setup on ASB!

```

## Challenges

### Challenge 1

> Challenges do not have step-by-step instructions

- [Create a dashboard visualizing blocked traffic](./challenges/blocked-traffic-dashboard/README.md)

### Challenge 2

- [Redirect `HTTP` requests to `HTTPS` in App Gateway](./challenges/redirect-http-to-https/README.md)

### Challenge 3

- Deploy Azure Container Registry [image](./challenges/azure-container-registry/README.md)

### Challenge 4

- [Deploy Web Validate](./challenges/deploy-WebV/README.md)

### Other ideas for exploring

- Explore `Azure Log Analytics` for observability
- Explore an idea from your experiences / upcoming customer projects
- Fix a bug that you ran into during the OpenHack
- Most importantly, `have fun and learn at the OpenHack!`

### Resetting the cluster

> Reset the cluster to a known state
>
> This is normally signifcantly faster for inner-loop development than recreating the cluster

```bash

# delete the namespaces
# this can take 4-5 minutes
### order matters as the deletes will hang and flux could try to re-deploy
kubectl delete ns flux-cd
kubectl delete ns ngsa
kubectl delete ns ingress
kubectl delete ns cluster-baseline-settings

# check the namespaces
kubectl get ns

# start over at Deploy Flux

```

### Running Multiple Clusters

- start a new shell to clear the ASB_* env vars
- start at `Set Team Name`
- make sure to use a new ASB_TEAM_NAME
- you must create a new branch or GitOps will fail on both clusters

## Delete Azure Resources

> Do not just delete the resource groups

Make sure ASB_TEAM_NAME is set correctly

```bash

echo $ASB_TEAM_NAME

```

Delete the cluster

```bash

# resource group names
export ASB_RG_CORE=rg-${ASB_TEAM_NAME}-core
export ASB_RG_HUB=rg-${ASB_TEAM_NAME}-networking-hub
export ASB_RG_SPOKE=rg-${ASB_TEAM_NAME}-networking-spoke

export ASB_AKS_NAME=$(az deployment group show -g $ASB_RG_CORE -n cluster-${ASB_TEAM_NAME} --query properties.outputs.aksClusterName.value -o tsv)
export ASB_KEYVAULT_NAME=$(az deployment group show -g $ASB_RG_CORE -n cluster-${ASB_TEAM_NAME} --query properties.outputs.keyVaultName.value -o tsv)
export ASB_LA_HUB=$(az monitor log-analytics workspace list -g $ASB_RG_HUB --query [0].name -o tsv)

# delete and purge the key vault
az keyvault delete -n $ASB_KEYVAULT_NAME
az keyvault purge -n $ASB_KEYVAULT_NAME

# hard delete Log Analytics
az monitor log-analytics workspace delete -y --force true -g $ASB_RG_CORE -n la-${ASB_AKS_NAME}
az monitor log-analytics workspace delete -y --force true -g $ASB_RG_HUB -n $ASB_LA_HUB

# delete the resource groups
az group delete -y --no-wait -g $ASB_RG_CORE
az group delete -y --no-wait -g $ASB_RG_HUB
az group delete -y --no-wait -g $ASB_RG_SPOKE

# delete from .kube/config
kubectl config delete-context $ASB_TEAM_NAME

# group deletion can take 10 minutes to complete
az group list -o table | grep $ASB_TEAM_NAME

### sometimes the spokes group has to be deleted twice
az group delete -y --no-wait -g $ASB_RG_SPOKE

```

## Delete git branch

```bash

git checkout main
git pull
git push origin --delete $ASB_TEAM_NAME
git fetch -pa
git branch -D $ASB_TEAM_NAME

```

### Random Notes

```bash

# stop your cluster
az aks stop --no-wait -n $ASB_AKS_NAME -g rg-bu0001a0008-$ASB_TEAM_NAME
az aks show -n $ASB_AKS_NAME -g rg-bu0001a0008-$ASB_TEAM_NAME --query provisioningState -o tsv

# start your cluster
az aks start --no-wait --name $ASB_AKS_NAME -g rg-bu0001a0008-$ASB_TEAM_NAME
az aks show -n $ASB_AKS_NAME -g rg-bu0001a0008-$ASB_TEAM_NAME --query provisioningState -o tsv

# disable policies (last resort for debugging)
az aks disable-addons --addons azure-policy -g rg-bu0001a0008-$ASB_TEAM_NAME -n $ASB_AKS_NAME

# delete your AKS cluster (keep your network)
### TODO - this doesn't work completely
az deployment group delete -g $ASB_RG_CORE -n cluster-${ASB_TEAM_NAME}

```
