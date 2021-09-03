# Deploying Canary and Weighted Round Robin Services with Traefik

## Challenge 01: Deploy Canary Service

- add information about adding a new service using ngsa-canary.yaml
- Fix image path
  - retaildevcrew/ngsa-app:blue
  - Needs to be available at docker.io
- discuss adding exposing the new service

### Hints

- talk about adding a new ingress route

## Challenge 02: Deploy Weighted Round Robin Service

- add information about adding a new `TraefikService` 
  - point out location
  - give some example related to actual config

```yaml 
apiVersion: traefik.containo.us/v1alpha1
kind: TraefikService
metadata:
  name: wrr-ngsa-memory
  namespace: ngsa

spec:
  weighted:
    services:
      - name: ngsa-memory
        port: 8080
        weight: 1
      - name: canary
        port: 8080
        weight: 1
```

- discuss adding exposing the new service
<!-- markdownlint-disable MD024 -->
### Hints
<!-- markdownlint-enable MD024 -->
- talk about TraefikService
- point to docs
