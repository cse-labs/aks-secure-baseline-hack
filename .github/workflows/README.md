# Setup service principal to manage DNS records for hack participants

This documentation walks through the steps needed to configure DNS updates through GitHub actions.

Prerequisites:

- Access to the subscription where the DNS Zone is located
- Permissions to create service principals and assign roles
- Permissions to add GitHub Action secrets to the repo

## Initial Setup

> You should only run this one time per repo

Create a service principal and give it permissions to manage DNS records in the DNS Zone for the hack.

```bash

# name of service principal
SP_NAME="http://github-action-dns"

# resource group of DNS Zone for the hack
DNS_ZONE_RG=TLD

# name of DNS Zone for the hack
DNS_ZONE_NAME=aks-sb.com

# create service principal and save credentials that will be saved to GitHub secret
AZURE_CREDENTIALS=$(az ad sp create-for-rbac -n $SP_NAME --skip-assignment --sdk-auth)

# fetch object id of service principal
SP_OBJECT_ID=$(az ad sp show --id $SP_NAME --query objectId -o tsv)

# fetch resource ID of DNS Zone
DNS_ZONE_ID=$(az network dns zone show -n $DNS_ZONE_NAME -g $DNS_ZONE_RG --query id -o tsv)

# fetch resource id of the DNS Zone resource group
DNS_ZONE_RG_ID=$(az group show -n $DNS_ZONE_RG --query id -o tsv)

# create the custom role to only manage "A" records.
az role definition create --role-definition "{
  'Name': 'github-action-dns',
  'Description': 'Custom role for GitHub Action to only manage DNS A records.',
  'AssignableScopes': ['$DNS_ZONE_RG_ID'],
  'Actions': [
    'Microsoft.Network/dnszones/A/read',
    'Microsoft.Network/dnszones/A/write',
    'Microsoft.Network/dnszones/A/delete'
  ]
}"

# add role assignment to allow service principal to manage dns records
az role assignment create --role "github-action-dns" --assignee-object-id $SP_OBJECT_ID --assignee-principal-type "ServicePrincipal" --scope $DNS_ZONE_ID

# Copy the output below into a GitHub secret named 'AZURE_CREDENTIALS'"
echo "$AZURE_CREDENTIALS"

```

## GitHub Action

The [GitHub Action](./dns.yml) can now use the service principal to update the required DNS Zone on behalf of the hack participants.

- a GitHub Action is configured to run this script when a hack participant pushes their branch changes to GitHub.
- `./create-dns-record.sh`
