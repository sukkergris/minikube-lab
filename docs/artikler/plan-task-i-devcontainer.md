# Plan: Artikel om at tilføje Task til din devcontainer

_Arbejdsplan for artiklen. Ikke selve artiklen._

## Formål

Artiklen viser, hvordan man tilføjer [Task](https://taskfile.dev) (`task`, også
kaldet go-task) til [Dockerfile.debian](../../.devcontainer/debian/Dockerfile.debian),
og bruger det som anledning til at forklare tre ting, der gælder for alle
programmer, man installerer på den måde:

1. Hvor filerne lander, når vi downloader dem.
2. Hvor programmet skal installeres, så `container-user` kan bruge det.
3. Hvordan `PATH` finder programmet bagefter.

**Læser:** En der kan følge en Dockerfile, men ikke har styr på filsystemet i
Linux, build layers og `PATH`.

**Placering:** `docs/artikler/task-i-devcontainer.md`, samme stil som
[locale.md](../devcontainer/locale.md): ændringen først, så forklaringen.

## Afklaringer før skrivning

- **`grep` downloader ikke.** `grep` søger i tekst. Det er `curl` (eller `wget`),
  der henter filer. Artiklen bør bruge `curl` til download, og kan vise `grep`
  i sin rigtige rolle, f.eks. til at finde den rigtige linje i en checksum-fil.
- **`curl` og `ca-certificates` står ikke i pakkelisten** i `Dockerfile.debian`
  i dag. Begge skal tilføjes: `curl` henter filen, `ca-certificates` gør at
  HTTPS-forbindelsen til GitHub kan verificeres.
- **Navnesammenfald:** På Debian hedder kommandoen fra pakken `taskwarrior` også
  `task`. Artiklen skal sige tydeligt, at det er Task fra taskfile.dev, og
  hvorfor vi ikke bare skriver `apt-get install task`.
- **CPU-arkitektur:** Releases findes som `amd64` og `arm64`. På en Mac med
  Apple Silicon er containeren `arm64`. Brug `dpkg --print-architecture` i
  stedet for at skrive `amd64` fast.
- **Version:** Lås til en bestemt version med `ARG TASK_VERSION=...`, så et
  build giver samme resultat hver gang. Slå den aktuelle version op på
  [releases-siden](https://github.com/go-task/task/releases) ved skrivning.

## Ændringen, artiklen bygger på

Udkast, som skal bygges og afprøves, før det kommer i artiklen:

```dockerfile
# tilføj til pakkelisten: ca-certificates, curl

ARG TASK_VERSION=<slå op>
RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_${ARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin task
```

Blokken skal stå **før** linjen `USER $USERNAME`, mens build stadig kører som
`root`. Det er hele pointen i afsnit 2.

## Disposition

### 1. Indledning

- Hvad Task er, i to sætninger, og hvorfor det er rart at have i sin devcontainer.
- De tre spørgsmål artiklen besvarer.

### 2. Hvor lander de filer, vi downloader?

Kernepunkter:

- `curl` gemmer ingenting af sig selv. Uden flag skriver den til stdout.
  - `curl -O` gemmer i **den mappe, kommandoen kører i**, med navnet fra URL'en.
  - `curl -o /sti/fil` gemmer præcis dér.
  - `curl ... | tar -xz -C /usr/local/bin task` gemmer aldrig arkivet på disk.
    Kun den udpakkede fil `task` lander, og den lander i mappen efter `-C`.
- I en Dockerfile er "den mappe, kommandoen kører i" bestemt af `WORKDIR`.
  Før linje 28 (`WORKDIR $HOME_DIR`) er der ingen `WORKDIR`, så `RUN` kører i `/`.
  Vis det med `RUN pwd`.
- `/tmp` er det rigtige sted til midlertidige filer, hvis man vil gemme arkivet
  først (f.eks. for at kontrollere en checksum).
- **Layers:** Hver `RUN` bliver et layer. En fil, der hentes i én `RUN` og
  slettes i den næste, fylder stadig i dit image. Hent, udpak og ryd op i samme
  `RUN`. Det er samme grund til, at linje 16 sletter `/var/lib/apt/lists/*` i
  samme `RUN` som `apt-get install`.
- Forskellen på build og kørsel: filer hentet i `Dockerfile.debian` er bagt ind
  i dit image. Filer hentet i terminalen bagefter ligger kun i den kørende
  container og forsvinder ved rebuild.

Mulig udvidelse: variant med checksum, hvor `grep` finder den rigtige linje i
`task_checksums.txt`, og `sha256sum -c` kontrollerer arkivet.

### 3. Hvor skal programmet installeres, så `container-user` kan bruge det?

Kernepunkter:

- To forskellige "brugere" er i spil, og de forveksles let:
  - `USER` i `Dockerfile.debian` bestemmer, hvem de efterfølgende `RUN`-linjer
    kører som under build.
  - `"remoteUser": "container-user"` i
    [devcontainer.json](../../.devcontainer/debian/devcontainer.json) bestemmer,
    hvem VS Code og terminalen kører som, når containeren er startet.
- Hvem der **installerer**, og hvem der **bruger**, er to spørgsmål. Det, der
  afgør om `container-user` kan køre programmet, er filens placering og
  rettigheder, ikke hvem der lagde den der.
- `/usr/local/bin` er stedet til programmer, man selv installerer uden om `apt`,
  og som alle brugere skal have. Mappen ejes af `root`, så installationen skal
  ske før `USER $USERNAME`. Filen får rettighederne `rwxr-xr-x`: kun `root` kan
  ændre den, alle kan køre den. Vis `ls -l /usr/local/bin/task`.
- Sammenlign de mulige placeringer i en lille tabel:

  | Placering | Hvem kan bruge det | Hvornår |
  | --- | --- | --- |
  | `/usr/bin` | alle | tilhører `apt`, rør den ikke selv |
  | `/usr/local/bin` | alle | egne installationer for hele systemet (valgt her) |
  | `~/.local/bin` | kun den ene bruger | installation uden `root` |

- Hvorfor ikke `~/.local/bin` her: det virker kun for `container-user`, og
  `sudo task` ville ikke finde programmet (se afsnit 4).
- Kort om alternativet: Tasks eget install-script med `-b /usr/local/bin`. Nævn
  det, men forklar hvorfor artiklen viser de enkelte trin i stedet.

### 4. Hvordan virker `PATH` her?

Kernepunkter:

- `PATH` er en liste af mapper adskilt af `:`. Shell'en leder fra venstre mod
  højre og tager det første match. Vis `echo $PATH | tr ':' '\n'`, `command -v task`
  og `type -a task`.
- Linje 6 i `Dockerfile.debian`:

  ```dockerfile
  PATH="/home/container-user/.local/bin:/usr/local/bin:$PATH"
  ```

  - `$PATH` udfyldes under build med værdien fra `debian:13`, som allerede
    indeholder `/usr/local/bin`. Mappen står der altså to gange. Det er
    harmløst, men værd at forklare, fordi læseren vil se det.
  - `ENV` gælder for alle efterfølgende `RUN`-linjer og for alle processer i
    containeren, uanset bruger.
  - `~/.local/bin` står først. Lægger `container-user` senere sin egen `task`
    dér, vinder den over den i `/usr/local/bin`.
- Konklusion for artiklen: `task` virker for `container-user`, fordi
  `/usr/local/bin` er i `PATH`, og det ville det også uden linje 6.
- Tre steder, hvor `PATH` kan være anderledes end forventet (skal afprøves i
  containeren, før de beskrives):
  - `sudo` bruger sin egen `secure_path` og ikke brugerens `PATH`.
    `/usr/local/bin` er med, `~/.local/bin` er ikke.
  - Login shells: `/etc/profile` og `/etc/zsh/zshenv` rører kun `PATH`, hvis
    den er tom (afprøvet, se afsnit 4b).
  - VS Code lægger selv mapper til `PATH` i terminalen i din devcontainer.
  - Dotfiles installeret med `stow` kan ændre `PATH` i `.zshrc`.

### 4b. Kontrast: hvad med programmer installeret med `apt-get`?

Kernepunkter (output er afprøvet i containeren):

- `apt-get` ændrer aldrig `PATH`. Pakken bestemmer selv, hvor filerne lægges,
  og det er altid i mapper, som allerede er i `PATH`: `/usr/bin` og `/usr/sbin`.
  Vis `dpkg -L stow | grep bin/` og `dpkg -S /usr/bin/git`.
- `apt-get` kan kun køre som `root`. Som `container-user` fejler den med
  `Permission denied` på `/var/lib/dpkg/lock-frontend`, og man bruger `sudo`.
- Der findes ingen installation "kun for `container-user`" med `apt-get`.
  Uanset om `root` kører den i `Dockerfile.debian`, eller `container-user`
  kører den med `sudo`, ejes filerne af `root` og kan køres af alle.
- Forskellen på de to brugere er derfor ikke, hvor programmet ligger, men
  hvilken `PATH` de leder med. Vis `echo $PATH` og `sudo sh -c 'echo $PATH'`.
- `sudo` skifter `PATH` ud med `secure_path` fra `/etc/sudoers`.
- `/etc/profile` og `/etc/zsh/zshenv` sætter kun `PATH`, hvis den er tom, så
  værdien fra `ENV` i `Dockerfile.debian` overlever.

### 5. Afprøvning

Efter rebuild, i terminalen i din devcontainer:

```bash
whoami                 # container-user
command -v task        # /usr/local/bin/task
ls -l /usr/local/bin/task
task --version
sudo task --version    # virker også via secure_path
```

Slut med en minimal `Taskfile.yml` og `task --list`, så læseren ser det virke.

### 6. Opsummering

Tre sætninger, én pr. spørgsmål fra indledningen.

## Arbejdsrækkefølge

1. Slå aktuel version og de præcise filnavne op på releases-siden.
2. Tilføj blokken til `Dockerfile.debian`, rebuild, og kør afprøvningen i afsnit 5.
3. Afprøv de tre `PATH`-forbehold i afsnit 4 og notér det faktiske output.
4. Skriv artiklen med rigtigt output fra trin 2 og 3.
5. Tilføj nye ord til cSpell, og kør markdownlint.

## Åbne spørgsmål

- Skal checksum-kontrol være med i hovedforløbet eller kun som udvidelse?
- Skal artiklen også vise installation fra terminalen (uden rebuild) som
  kontrast til installation i `Dockerfile.debian`?
