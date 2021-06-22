#!/bin/bash

# resource group of DNS Zone for the hack
DNS_ZONE_RG=TLD

# name of DNS Zone for the hack
DNS_ZONE_NAME=aks-sb.com

if [ -z "$ASB_TEAM_NAME" ]
then
  echo "ASB_TEAM_NAME name is required"
  exit
fi

if [ -z "$ASB_AKS_PIP" ]
then
  echo "ASB_AKS_PIP is required"
  exit
fi

# fetch resource id of dns record
DNS_RECORD_ID=$(az network dns record-set a show -g $DNS_ZONE_RG -z $DNS_ZONE_NAME -n $ASB_TEAM_NAME --query id -o tsv)

# delete existing record if it exists
if [ -n "$DNS_RECORD_ID" ]
then
  az network dns record-set a delete -g $DNS_ZONE_RG -z $DNS_ZONE_NAME -n $ASB_TEAM_NAME -y
fi

# create the dns record
az network dns record-set a add-record -g $DNS_ZONE_RG -z $DNS_ZONE_NAME -n $ASB_TEAM_NAME -a $ASB_AKS_PIP --query fqdn
