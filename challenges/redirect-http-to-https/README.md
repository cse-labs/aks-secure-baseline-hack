# Redirect `HTTP` Requests to `HTTPS` in App Gateway

## Background

For security reasons, when the App Gateway receives an HTTP request, redirect to HTTPS. This challenge is broken into parts: manual configuration and setup via the ARM template.

## Part 1: Manual Configuration

### Resources

> It is recommended to configure the redirect with the Azure Portal first and then with Azure CLI to better understand the flow. To debug blocked traffic, reference the [Log Analytics Workspace](../blocked-traffic-dashboard/README.md#log-analytics-workspace) query notes.

- Configuration via the Azure Portal by [Adding a listener and redirection rule](https://docs.microsoft.com/en-us/azure/application-gateway/redirect-http-to-https-portal#add-a-listener-and-redirection-rule)
- Configuration via the Azure CLI by [Adding a listener and redirection rule](https://docs.microsoft.com/en-us/azure/application-gateway/redirect-http-to-https-cli#add-a-listener-and-redirection-rule)

### Test Manual Configuration

```bash
# Test HTTP redirect for a 301
curl -i http://${ASB_DOMAIN}/memory/healthz
```

## Part 2: Setup via ARM Template

> If [Part 1](#part-1:-manual-configuration) is complete, the ARM template values are available in the Azure Portal via `JSON View` of each resource

- In the deployment file, `cluster-stamp.json`
  - Add a frontend port to the app gateway resource
  - Add a listener to the app gateway resource
  - Add a redirect configuration to the app gateway resource
  - Add a routing rule to the app gateway resource
- In the networking spoke ARM template, add a security rule to the app gateway network security group that allows inbound traffic on port 80

### Test ARM Template

- Deploy the network
- Create AKS
- Test HTTP redirect for a 301

```bash
curl -i http://${ASB_DOMAIN}/memory/healthz
```
