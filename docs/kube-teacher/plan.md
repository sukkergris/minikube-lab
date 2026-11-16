# Kubernetes-læringsplan

Start: 2026-11-17 · Tempo: ca. 4 timer om dagen, 5 dage om ugen · Lab: kind på Docker-in-Docker

Planen følger modulerne i `kube-teacher` skill. Du starter hver dag med `/kube-teacher`, og skill'en holder styr på, hvor du er, i [progress.md](progress.md).

Datoerne er et estimat. Er noget svært, så tag en dag mere. Kan du det allerede, så spring videre. Målet er at du kan det, ikke at du holder tidsplanen.

## Sådan ser en dag ud

| Tid | Hvad |
|-----|------|
| 0:00–0:15 | Opvarmning: 3–5 quiz-spørgsmål om i går |
| 0:15–1:45 | Nyt modul: kort koncept, derefter bygger du det selv |
| 1:45–2:00 | **Pause væk fra skærmen** |
| 2:00–3:15 | Ødelæg og fejlsøg: Claude laver en fejl, du finder den |
| 3:15–3:45 | Eget eksperiment eller læsning på kubernetes.io |
| 3:45–4:00 | Opsummering: hvad sidder fast, hvad er usikkert. Progress opdateres |

Fire timer med nyt stof hver dag er meget. Tag pausen alvorligt, og hold weekenden fri. Hjernen gemmer det lærte, når du *ikke* arbejder.

## Uge 1 – Fundament (Del 1)

| Dag | Modul | Du kan bagefter |
|-----|-------|-----------------|
| 1 | 0 Setup + 1 Første Pod | Tilføje kubectl og kind i `Dockerfile.debian`, rebuilde, oprette dit cluster med `lab/kind-config.yaml`, skrive `task k8s:up/down/reset`, køre og inspicere en Pod |
| 2 | 2 Labels + 3 Deployment | Bruge selectors, skalere, lave rolling update og `rollout undo` |
| 3 | 4 Services + 5 Namespaces | Nå din app via ClusterIP, NodePort og `port-forward`, bruge DNS i dit cluster, skifte namespace og context |
| 4 | Repetition | Ødelæg-og-fejlsøg-dag med alle Del 1-fejl. Oversæt en af dine Compose-filer til manifests |
| 5 | Buffer + quiz | Indhente det, der hang. Stor quiz på Del 1 |

**Milepæl:** Du kan slette dit cluster og bygge din app op igen fra filer i `lab/` uden hjælp.

## Uge 2 – Konfiguration og drift (Del 2)

| Dag | Modul | Du kan bagefter |
|-----|-------|-----------------|
| 6 | 6 ConfigMap og Secret | Styre config med env vars og filer, og forklare hvorfor Secrets ikke er krypterede |
| 7 | 7 Health checks | Bruge liveness-, readiness- og startup-probes, og se forskellen i praksis |
| 8 | 8 Resources | Sætte requests og limits, forstå QoS, finde OOMKilled og Pending, bruge `kubectl top` |
| 9 | 9 Storage | Bruge PVC og StorageClass, og køre PostgreSQL som StatefulSet |
| 10 | 10 Ingress | Installere en ingress controller, lave host- og path-routing, og få et første kig på Gateway API |

**Milepæl:** Din app overlever genstart af Pods og bevarer data. Den kan nås via et hostname.

## Uge 3 – Som i virkeligheden (Del 3, første halvdel)

| Dag | Modul | Du kan bagefter |
|-----|-------|-----------------|
| 11 | 11 Hele appen, del 1 | Køre API, database, config og ingress samlet i `lab/` |
| 12 | 11 Hele appen, del 2 | Slette alt og genopbygge det fra bunden. Fejlsøge to fejl på én gang |
| 13 | 12 Kustomize | Lave base og overlays til dev og prod med `kubectl apply -k` |
| 14 | 13 Helm | Installere og konfigurere et chart og pakke din egen app som chart |
| 15 | Repetition | Ødelæg-og-fejlsøg-dag med fejl fra Del 2, valgt ud fra det der står som "Usikkert" |

**Milepæl:** "Jeg kan faktisk det her." Hele appen kører og kan genskabes med én kommando.

## Uge 4 – Avanceret (Del 3, anden halvdel)

| Dag | Modul | Du kan bagefter |
|-----|-------|-----------------|
| 16 | 14 Scheduling | Køre kind med flere nodes, bruge nodeSelector, affinity, taints og tolerations, og DaemonSet |
| 17 | 15 Jobs/CronJobs + 16 RBAC | Køre batch-opgaver, oprette ServiceAccounts og Roles, bruge `kubectl auth can-i` |
| 18 | 17 NetworkPolicy | Lave default deny og kun tillade adgang fra API til DB |
| 19 | 18 GitOps | Lade Argo CD synkronisere `lab/` fra git |
| 20 | Afslutning | Bygge alt op fra et tomt cluster via GitOps. Evaluere forløbet og vælge næste mål |

**Milepæl:** Et git push opdaterer dit cluster.

## Uge 5–6 (valgfrit) – Certificering

Hvis målet er CKAD eller CKA:

- Daglige opgaver med tidsgrænse, kun med kubernetes.io åben
- Imperative kommandoer (`kubectl create ... --dry-run=client -o yaml`) og `kubectl explain`
- Officielt curriculum fra Linux Foundation og øve-eksamener på killer.sh
- CKA kræver desuden kubeadm, etcd-backup og fejlsøgning af nodes. Det skal du bruge et ekstra par dage på

## Tips

- **Skriv selv.** Copy-paste lærer dig ingenting. Brug `kubectl explain <resource>.spec`, når du er i tvivl.
- **Sig til, når det keder dig eller bliver for svært.** Planen bliver justeret.
- **Dine gamle noter** fra kurset ligger stadig i [K8s/](../K8s/) og [kubernetes-course/](../kubernetes-course/). Brug dem som opslag, ikke som pensum.
