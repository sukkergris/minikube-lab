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

- Installere værktøjer via Dockerfile med pinned `ARG` og `TARGETARCH`
- Oprette, slette og nulstille cluster med kind og egne tasks
- Version skew: kubectl ±1 minor fra API server; node image bestemmer
  Kubernetes-versionen
- Slår selv op i `--help`

## Usikkert

- Læse fejlbeskeder nedefra (digest-fejlen, `Is a directory`): gentag ved
  første `kubectl describe`/Events
- Shell-detaljer: `-o` skal have en fil, ikke en mappe; `chmod` efter download
- Ikke afprøvet endnu: hvad control plane Pods i `kube-system` laver, og
  hvorfor en node er `NotReady` lige efter oprettelse

## Aktiv opgave

Modul 0, trin 3 (sidste): autocompletion og `k` alias i zsh (`.zshrc` ligger i
dotfiles; pak ind i `command -v kubectl`). Accept: `k get no<Tab>` giver
`nodes`, og `k describe node <Tab>` foreslår `lab-001-kind-control-plane`.

Refleksionsspørgsmål, der mangler svar:

1. Hvorfor var din node `NotReady` og `coredns` `Pending` de første sekunder
   efter reset? (svar: venter på CNI, `kindnet`)
2. Hvad er væk efter `cluster-reset`, og hvad overlever? (filerne i `lab/`)

Trin 1 og 2 er færdige: kubectl 1.37.2 og kind 0.33.0 via Dockerfile,
`lab/kind-config.yaml` med node image pinned på digest og port 80/443, tasks
`lab001:cluster-create/destroy/reset/info` og `context-current`.

Små løse ender (valgfrit): task til `kubectl get nodes,pods -A`; cluster-navn
som `vars:` i `Taskfile.LAB001.yml`; kommentaren "Assumes docker" står over
kubectl i stedet for kind; `scripts/install.sh` er et testscript.

## Sidespor

Parkeringsplads for ting uden for opgaven. Regel: **nu**, hvis det blokerer
opgaven eller kan klares i samme rebuild; ellers **parkér** og tag det i
slutningen af en session.

- [ ] nvim 0.12.x i Dockerfile (i gang 2026-11-17, samme rebuild som kubectl
  completion; asset-navn `x86_64` vs. `TARGETARCH=amd64`, arkiv med
  `bin/lib/share`)
- [ ] Valgfrit: kubectl-URL med `/release/`, `USER_BIN` → `LOCAL_BIN`,
  stavning i kommentaren om `TARGETARCH`, checksum-verifikation

## Næste gang

Start med `task lab001:cluster-create` hvis dit cluster er væk, afslut modul 0
(trin 3 og de to spørgsmål, ca. 15 min.), og gå så til modul 1: Første Pod.

## Log
- 2026-11-16: Session 1 startet. Lab-repo fundet i `/xyz`. Docker-in-Docker kører
  (29.9.3), arkitektur amd64. kubectl og kind mangler endnu.
- 2026-11-16: Trin 1 færdigt. Skrev selv Dockerfile-blokkene, skiftede til
  BuildKits `TARGETARCH`, testede download i et script først. Lærte undervejs:
  `ARG` kører ikke en shell, `>` vs. `-o` vs. `|`, FHS (`/usr/local/bin`),
  version skew (kubectl ±1 minor fra API server; kind vælger node image).
  Bruger selv `--help` til at finde svar.
- 2026-11-16: Trin 2 færdigt. Cluster `lab-001-kind` oppe på v1.37.0, fandt
  node image i release notes, løste digest-fejl (manglende tegn), skrev tasks
  inkl. `cluster-reset` med `task:`-kald. Stoppede før trin 3.
