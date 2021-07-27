# Creating a Dashboard Visualizing Blocked Traffic

## Background

There are multiple locations where traffic is blocked for security reasons. Create a dashboard to easily monitor the frequency of blocked traffic, in order to gain visibility into intentional and unintentional spikes.

## Resources
  
- Firewall and NSG specific details to use in log queries: [Log Analytics Workspace](#log-analytics-workspace)
- [Resource on query syntax](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/get-started-queries)
- [Resource to create dashboard](https://docs.microsoft.com/en-us/azure/azure-monitor/visualize/tutorial-logs-dashboards)

## Log Analytics Workspace

### Create Blocked Traffic

```bash
curl -i http://${ASB_DOMAIN}/memory/healthz
```

### Core Resource Group

- The logs have `AzureDiagnostics` entries
- Query for distinct `Category` values
- Filter entries on `Category` value(s) that contain insights on what the Application Gateway is evaluating, matching, and blocking
- Create graph and add to dashboard

### Hub Resource Group

- The logs have `AzureDiagnostics` entries
- Query for distinct `Category` values
- Filter entries on `Category` value(s) that contain insights on the following
  - Firewall rules
  - Network Security Group rules
- Create graph(s) and add to dashboard
