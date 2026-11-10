# Kapitel 13: Minikube i en devcontainer

_En opdateret udgave af [Capter-13.md](Capter-13.md), tilpasset denne devcontainer (2026)_

## Hvorfor en ny udgave

Videoen i kapitel 13 er optaget omkring 2020 med Kubernetes 1.18 på en Ubuntu-maskine
med VirtualBox. Det meste af indholdet holder stadig, men tre ting passer ikke her:

| Videoen | Her | Hvorfor |
| --- | --- | --- |
| `--driver=virtualbox` | `--driver=docker` | Vi kører i en container. Der er ingen `/dev/kvm`, og en hypervisor kan ikke installeres inde i en container. |
| Tjek virtualisering i BIOS | Spring over | Docker driver kræver ikke hardware-virtualisering. |
| `minikube service ... --url` i en browser | `kubectl port-forward` | Minikubes IP ligger i Docker-netværket inde i vores container og kan ikke nås fra værtsmaskinens browser. |

Vores devcontainer er bygget til netop dette: Den hedder `minikube-lab` og har
docker-in-docker slået til i
[`devcontainer.json`](../../../.devcontainer/debian/devcontainer.json).

Videoen advarer om, at Docker driver "kan give sikkerheds- eller datatabsproblemer".
Den advarsel gælder, når man kører direkte på sin egen maskine. Her er vores
devcontainer selv den sandkasse, som underviseren brugte en VirtualBox VM til. Går
noget galt, laver du bare et rebuild af din devcontainer.

## Overblik

```text
Værtsmaskine (Arch Linux)
└── devcontainer (Debian 13)          ← du arbejder her
    ├── kubectl, minikube
    └── Docker daemon (docker-in-docker)
        └── container "minikube"      ← hele Kubernetes cluster
```

## 1. Tjek at Docker virker

```bash
docker info --format '{{.ServerVersion}}'
```

Kommandoen skal skrive et versionsnummer. Får du `permission denied`, er din bruger
ikke i `docker`-gruppen. Lav i så fald et rebuild af din devcontainer.

## 2. Installér kubectl

Installér `kubectl` **før** minikube. Så konfigurerer minikube automatisk
`~/.kube/config`, når dit cluster starter.

```bash
cd /tmp
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Valgfrit, men anbefalet: verificér checksum
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

sudo install -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl kubectl.sha256

kubectl version --client
```

`sudo install` gør det samme som videoens `chmod +x` og `mv` til `/usr/local/bin`,
bare i én kommando.

Kilde: <https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/>

## 3. Installér minikube

```bash
cd /tmp
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

minikube version
```

Kilde: <https://minikube.sigs.k8s.io/docs/start/>

## 4. Start dit cluster

```bash
minikube start --driver=docker
```

Første gang henter minikube sit base image (`kicbase`) og Kubernetes-binærfilerne. Det
tager et par minutter. I stedet for en VM i VirtualBox får du en container, som du
kan se med:

```bash
docker ps --filter name=minikube
```

Vil du gøre Docker til standard driver, så du kan nøjes med `minikube start`:

```bash
minikube config set driver docker
```

## 5. Tjek status

```bash
minikube status
```

Forventet output (nyere versioner viser lidt flere felter end videoen):

```text
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

```bash
kubectl get nodes
```

Du skal se én node med navnet `minikube` og status `Ready`. Versionen er nyere end
videoens 1.18, og det er helt fint.

## 6. Test med en deployment

Opret en deployment og eksponér den som en service. Du behøver ikke forstå
kommandoerne endnu, de bliver gennemgået senere i kurset.

```bash
kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl get deployments

kubectl expose deployment hello-minikube --type=NodePort --port=8080
kubectl get services hello-minikube
```

> Videoen bruger `k8s.gcr.io/echoserver`. Registret `k8s.gcr.io` er udfaset og
> erstattet af `registry.k8s.io`. Brug image ovenfor, som minikubes egen
> dokumentation bruger i dag.

## 7. Åbn applikationen i en browser

Videoen bruger `minikube service hello-minikube --url`. I vores devcontainer giver det
en adresse som `http://192.168.49.2:3xxxx`, som kun kan nås inde fra din devcontainer:

```bash
curl "$(minikube service hello-minikube --url)"   # virker inde i din devcontainer
```

For at åbne den i en browser på værtsmaskinen skal du bruge port forwarding:

```bash
kubectl port-forward service/hello-minikube 8080:8080
```

VS Code opdager port 8080 og videresender den automatisk (se fanen **Ports**). Åbn
<http://localhost:8080>. Echo server svarer med detaljer om din request. Stop port
forwarding med `Ctrl+C`.

## 8. Ryd op

```bash
kubectl delete service hello-minikube
kubectl delete deployment hello-minikube
```

Dit cluster kan stoppes eller slettes helt:

```bash
minikube stop      # pause, kan startes igen med minikube start
minikube delete    # slet dit cluster helt og start forfra
```

`minikube delete` svarer til at smide VirtualBox VM væk i videoen.

## Efter et rebuild af din devcontainer

`kubectl`, `minikube` og dit cluster ligger kun i filsystemet i din devcontainer.
Efter et rebuild er de væk, og trin 2 til 4 skal køres igen. Det er fint, mens du
lærer. Hvis det bliver irriterende, kan installationen lægges i
[`post-create.sh`](../../../.devcontainer/scripts/post-create.sh):

```bash
# Install kubectl and minikube
arch=amd64
curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${arch}/kubectl"
sudo install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
curl -fsSLo /tmp/minikube "https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-${arch}"
sudo install -m 0755 /tmp/minikube /usr/local/bin/minikube
rm -f /tmp/kubectl /tmp/minikube
```

## Fejlsøgning

| Symptom | Løsning |
| --- | --- |
| `The "docker" driver should not be used with root privileges` | Kør som `container-user`, ikke med `sudo`. |
| `permission denied ... docker.sock` | Din bruger er ikke i `docker`-gruppen. Lav et rebuild af din devcontainer. |
| Dit cluster starter ikke eller hænger | `minikube delete` og derefter `minikube start --driver=docker`. |
| `kubectl` taler med et forkert cluster | `kubectl config use-context minikube` |
| En browser kan ikke nå `192.168.49.x` | Forventet. Brug `kubectl port-forward` (trin 7). |
| Log fra minikube | `minikube logs` |
