# Kubernetes-læring – status

Lab: kind (cluster-navn: `lab-001-kind`, context `kind-lab-001-kind`; tasks i `Taskfile.LAB001.yml` under namespace `lab001`)
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
Modul 0, trin 1 (færdigt 2026-11-16): kubectl 1.37.2 og kind 0.33.0 installeret
via Dockerfile med `TARGETARCH` og pinned `ARG`.

Modul 0, trin 2 (færdigt 2026-11-16): `lab/kind-config.yaml` med node image
pinned på digest og port 80/443; tasks `lab001:cluster-create/destroy/reset/info`
og `context-current` virker.

Modul 0, trin 3 (sidste): autocompletion og `k` alias i zsh (dotfiles), samt
refleksionsspørgsmålene (NotReady lige efter reset; hvad forsvinder ved reset).

## Næste gang
Modul 0: Setup (fortsæt fra "Aktiv opgave")

## Log
- 2026-11-16: Session 1 startet. Lab-repo fundet i `/xyz`. Docker-in-Docker kører
  (29.9.3), arkitektur amd64. kubectl og kind mangler endnu.
- 2026-11-16: Trin 1 færdigt. Skrev selv Dockerfile-blokkene, skiftede til
  BuildKits `TARGETARCH`, testede download i et script først. Lærte undervejs:
  `ARG` kører ikke en shell, `>` vs. `-o` vs. `|`, FHS (`/usr/local/bin`),
  version skew (kubectl ±1 minor fra API server; kind vælger node image).
  Bruger selv `--help` til at finde svar.
