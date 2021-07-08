# Deploying from Azure Container Registry

## Challenge

> Load image into Azure Container Registry and deploy

- Load the image from `ghcr.io/retaildevcrews/ngsa-app:beta` into ACR
- Modify `ngsa-memory.yaml` to use ACR
- Redeploy `ngsa-memory`

### Deploy from GitHub Container Registry (optional)

The recommended approach is to use ACR as your image repo for AKS Secure Baseline. In some situations, you may want to pull from an external, trusted repo.

This part of the challenge is optional and demonstrates the changes necessary.

- Deloy `ngsa-ghcr.yaml` from this directory
  - The pod will fail to start due to `ErrImgPull`
- Delete the deployment

## Remediation

- Update the Azure image source policy
- Update the application firewall rule

## Hints

> Docker pull gets redirected from ghcr.io

- Add the following FQDNs in addition to ghcr.io
  - *.ghcr.io
  - *.githubusercontent.com
