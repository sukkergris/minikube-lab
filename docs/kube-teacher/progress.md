# Kubernetes-læring – status

Lab: kind (cluster-navn: `lab`)
Mål: CKAD (Linux Foundation), valgt 2026-11-16. Evt. CKA bagefter. Eksamensøvelser lægges ind efter Del 2; `kubectl explain` og imperative kommandoer (`--dry-run=client -o yaml`) trænes fra modul 1.
Tid pr. uge: ca. 20 timer (4 timer om dagen, 5 dage om ugen, jf. [plan.md](plan.md))

## Moduler

### Del 1 – Fundament
- [ ] 0 Setup
- [ ] 1 Første Pod
- [ ] 2 Labels og selectors
- [ ] 3 ReplicaSet og Deployment
- [ ] 4 Services
- [ ] 5 Namespaces og kubectl-kontekst

### Del 2 – Konfiguration og drift
- [ ] 6 ConfigMap og Secret
- [ ] 7 Health checks
- [ ] 8 Resources
- [ ] 9 Storage
- [ ] 10 Ingress

### Del 3 – Som i virkeligheden
- [ ] 11 Hele appen
- [ ] 12 Kustomize
- [ ] 13 Helm
- [ ] 14 Scheduling
- [ ] 15 Jobs og CronJobs
- [ ] 16 RBAC og ServiceAccounts
- [ ] 17 NetworkPolicy
- [ ] 18 GitOps

## Sikkert

## Usikkert

## Aktiv opgave
Modul 0, trin 1: tilføj kubectl (1.37.2) og kind (0.33.0) i
`.devcontainer/debian/Dockerfile.debian` med pinned `ARG`, og rebuild din
devcontainer. Verificér med `kubectl version --client` og `kind version`.

Derefter: `lab/kind-config.yaml`, `Taskfile.K8S.yml` (`k8s:up/down/reset/status`),
`task k8s:up`, og `kubectl get nodes` viser en node i `Ready`.

## Næste gang
Modul 0: Setup (fortsæt fra "Aktiv opgave")

## Log
- 2026-11-16: Session 1 startet. Lab-repo fundet i `/xyz`. Docker-in-Docker kører
  (29.9.3), arkitektur amd64. kubectl og kind mangler endnu.
