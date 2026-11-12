# Status på Minikube-installation i devcontainer

## Hvad der er på plads nu

1. **Basis-container ([Dockerfile.debian](../.devcontainer/debian/Dockerfile.debian) & [docker-compose.yml](../.devcontainer/debian/docker-compose.yml)):**
   - Kører `debian:13` med brugeren `container-user` (med passwordløs `sudo` og `zsh`).
   - Volumes til `.claude`, `.gemini`, `.ssh` og `.sshtemplate` er monteret og får sat ejerskab i [post-create.sh](../.devcontainer/scripts/post-create.sh).
2. **Docker-in-Docker ([devcontainer.json](../.devcontainer/debian/devcontainer.json)):**
   - Featuren `ghcr.io/devcontainers/features/docker-in-docker` (`"moby": "false"`) er tilføjet, så Minikube kan køre med Docker-driveren inde i devcontaineren.
3. **Guide til manuel installation ([Chapter-13-minikube-devcontainer.md](kubernetes-course/section-3/Chapter-13-minikube-devcontainer.md)):**
   - Opdateret guide tilpasset denne devcontainer er klar.
4. **Noter ([yaml.md](K8s/yaml.md)):**
   - Første udkast til en Pod-definition (`myapp-pod`). *(Bemærk en lille stavefejl på linje 10: `lables:` -> `labels:`).*

---

## Næste skridt: Manuel installation inde i devcontaineren

Minikube og `kubectl` installeres manuelt i terminalen inde i devcontaineren ved at følge [Chapter-13-minikube-devcontainer.md](kubernetes-course/section-3/Chapter-13-minikube-devcontainer.md):

### 1. Tjek at Docker virker
```bash
docker info --format '{{.ServerVersion}}'
```

### 2. Installér `kubectl`
*(Hvis `curl` mangler: `sudo apt-get update && sudo apt-get install -y curl ca-certificates`)*
```bash
cd /tmp
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client
```

### 3. Installér `minikube`
```bash
cd /tmp
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
minikube version
```

### 4. Start clusteret
```bash
minikube start --driver=docker
minikube status
kubectl get nodes
```
