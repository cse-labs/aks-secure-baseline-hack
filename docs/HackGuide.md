# ASB Hack Guide

## Pre-Hack

### Attendee Prerequisites

- Working knowledge of Docker, Kubernetes and AKS
- GitHub ID with 2FA enabled
- AIRS subscription with owner privileges

### Process

- Recruit Coaches
  - Questions will come up especially during `Challenges`
  - Teams will sometimes need focused help and coaches are needed to scale
- `Challenges` Concept
  - Overview presentation and first setup takes most of day 1
  - Readme contains a list of ideas
  - Some teams will come up with their own ideas
  - There is a /challenges folder
    - Check in work in-progress
    - Encourage early PRs
    - Do NOT check in cluster config files!
- See something, say something
  - Encourage hack teams to report issues / bug
  - Encourage hack teams to ask questions early rather than remain blocked
- Stand ups
  - We generally do two stand ups / day
    - Keep them short and focused
    - For a large hack, consider team leads and scrum of scrums
  - Demos at the afternoon stand up!
- Retros
  - We suggest 30 minutes of `Challenge` demos
  - 30 minutes of retro

### Azure Subscription

- Each attendee should have an Azure AIRS Subscription
- Create Azure Security Group via [idweb](https://idweb/)
- Add hack attendees to security group
- Check Azure Quotas and increase if needed
  - Public IPs default to 100 and each cluster needs 4 PIPs
  - Each cluster deploys 5 VMs
  - Make sure you have quota and budget
    - We suggest 1.5-2 clusters per attendee for quota (e.g., cost, public IPs, cores, etc.)
    - Encourage deleting unused resources

### Repo Setup

- Set the `ASB_TENANT_ID` repo secret to your Azure Subscription Tenant ID
- Set branch protection rule on `main`
- **Do NOT merge a PR with the cluster generated files into `main`**
- Add users to GitHub org
- Grant write priveleges to repo
- Validate Codespaces access before hack
  - Some people may start early
  - Keep content simple until hack starts

### Communication Setup

- Setup Teams or use GitHub Discussions
  - Most hacks will have multiple breakout teams
  - Add coaches to breakout teams
  - We used `Teams Meetings` (not channels or chats) and it worked well
  - Encourage everyone to use the `Join` button and work `in the open`
  - Allows coaches to `drop in`

## Execution

> Duration: 2-3 days is a good estimate to go deeper via `Challenges`

### Day 1 Agenda

- Intros
- Validate and resolve access issues
- Review `Working Agreement` and `Code of Conduct`
- AKS Secure Baseline Overview and Architecture
  - We used the PnP repo and Azure Portal of a deployed cluster
  - Plan for a lot of questions
- Break into teams of 4-6
  - Each team deploys an ASB cluster
    - We used colors
    - It needs to be short for ASB_TEAM_NAME
    - red1, blue1, green1 ...
  - One person should drive the entire initial setup
  - Do not try to switch off in the middle the first time
- Each team works through the first challenge
  - Add https auto-redirect to App Gateway
  - Two part challenge
    - Add to existing cluster
    - Update ARM Template
    - Delete existing cluster
    - Deploy new cluster
- Stand Up and Challenge Planning
  - Stand up - especially blockers
  - Encourage attendees to clean-up unused clusters
  - Plan Challenge Teams
    - We let attendees self-select
    - 2-5 seems ideal
    - Coaches support, so not too many teams
    - Challenge order is not important after Challenge 1

### Day 2+ Agenda

- Stand up
  - Make sure everyone is on a challenge team
  - Deal with blockers
- Hack on Challenges
  - **If blocked, ask for help!**
- Social / Team Building Event
  - Adding a social or team building event to one or more of the days helps the team get to know each other better
    - Simple games like pictionary
    - Online break-out rooms
    - Virtual shopping to find cool / weird items
- Stand up
  - Demos
  - Deal with blockers
  - Adjust / create new challenge teams
  - Encourage attendees to clean up unused clusters

### Day n Agenda

- Finish demos
- PR work into main branch (/challenges directory)
- Clean up unused clusters
- Demos, demos, demos
- Retrospective

### Tips

- Tightly couple `teams` to `branches`
  - GitOps is really challenging otherwise
  - The ASB_TEAM_NAME has several constraints based on resource naming rules
  - Do NOT merge team (cluster) branches into main
  - There are 4 files that are generated and should never be in main
    - flux.yaml
    - {ASB_TEAM_NAME}.asb.env
    - ngsa-ingress.yaml
    - 02-traefik-config.yaml
- Open the `readme` in a browser on GitHub
  - This gives you a copy button for the fences
    - Codespaces does not
    - This avoids copy-paste errors
- Beware `soft deletes`
  - Deployment will fail if the name is reused and a soft delete exists
  - Make sure to run `./cleanup.sh teamName`
  - Partial deploys may have to be deleted by hand
  - Soft deleted key vaults are easy to purge from the portal
  - Soft deleted Log Analytics Workspaces are not
- ASB uses a number of preview features
  - Sometimes, these change and things break
  - Make sure to understand the preview features in use
- One person should drive the entire initial setup
- Do not try to switch off in the middle the first time
- Once setup, everything the other team members need is in the team branch

### Adding SSL Certs

> These are already set in the `asb-spark` repo

Create three `repo level Codespaces secrets` in your repo and set the values to the results of the commands below

These secrets will be securely loaded into env vars in the Codespace

If attendees are not using Codespaces, they will need to get these values from Key Vault or another method

```bash

# APP_GW_CERT
az keyvault secret show --subscription bartr-wcnp --vault-name rdc-certs -n aks-sb --query "value" -o tsv | tr -d '\n'

# INGRESS_CERT
az keyvault secret show --subscription bartr-wcnp --vault-name rdc-certs -n aks-sb-crt --query "value" -o tsv | base64 | tr -d '\n'

# INGRESS_KEY
az keyvault secret show --subscription bartr-wcnp --vault-name rdc-certs -n aks-sb-key --query "value" -o tsv | base64 | tr -d '\n'

```

### Videos

- Overview videos of aks-secure-baseline and deployed components
  - [Part 1](https://msit.microsoftstream.com/video/e59c0840-98dc-a7ab-5f7b-f1ebb810bf2b?channelId=533aa1ff-0400-85a8-6076-f1eb81fb8468)
  - [Part 2](https://msit.microsoftstream.com/video/e59c0840-98dc-a7ab-1e9d-f1ebb810d1a2?channelId=533aa1ff-0400-85a8-6076-f1eb81fb8468)
