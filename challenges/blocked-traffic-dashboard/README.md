# Creating a Dashboard Visualizing Blocked Traffic

## Background

There are multiple locations where traffic is blocked for security reasons. Create a dashboard to easily monitor the frequency of blocked traffic, in order to gain visibility into intentional and unintentional spikes.

## Resources
  
- Firewall and NSG specific details to use in log queries: [Log Analytics Workspace](#log-analytics-workspace)
- [Resource on query syntax](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/get-started-queries)
- [Resource to create dashboard](https://docs.microsoft.com/en-us/azure/azure-monitor/visualize/tutorial-logs-dashboards)

## Log Analytics Workspace

### Core Resource Group

- The logs have `AzureDiagnostics` entries
- To filter on entries that contain insights on what the WAF (Web Application Firewall) is evaluating, matching, and blocking, use the `ApplicationGatewayFirewallLog` category,

### Hub Resource Group

- The logs have `AzureDiagnostics` entries
- To filter on resource logs for firewall application rules, use the `AzureFirewallApplicationRule` category
- To filter on resource logs for firewall network rules, use the `AzureFirewallNetworkRule` category
- To filter on logs where the NSG (Network Security Group) rules were applied, use the `NetworkSecurityGroupRuleEvent` category
