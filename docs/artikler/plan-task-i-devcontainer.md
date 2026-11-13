# Plan: Artikel om at tilføje Task til din devcontainer

_Arbejdsplan for artiklen. Ikke selve artiklen._

## Formål

Artiklen viser, hvordan man tilføjer [Task](https://taskfile.dev) (`task`, også
kaldet go-task) til [Dockerfile.debian](../../.devcontainer/debian/Dockerfile.debian),
og bruger det som anledning til at forklare tre ting, der gælder for alle
programmer, man installerer på den måde:

1. Hvor filerne lander, når vi downloader dem.
2. Hvor programmet skal installeres, så `container-user` kan bruge det, når
   din devcontainer starter med `"remoteUser": "container-user"`.
3. Hvordan `PATH` finder programmet bagefter.

**Læser:** En der kan følge en Dockerfile, men ikke har styr på filsystemet i
Linux, build layers og `PATH`.

**Placering:** `docs/artikler/task-i-devcontainer.md`, samme stil som
[locale.md](../devcontainer/locale.md): ændringen først, så forklaringen.

**Den røde tråd:** Hvem der _installerer_, og hvem der _bruger_, er to
forskellige spørgsmål. `root` installerer, `container-user` bruger.

## Afklaringer før skrivning

- **`grep` downloader ikke.** `grep` søger i tekst. Det er `curl` (eller `wget`),
  der henter filer. Artiklen bruger `curl` til download og kan vise `grep` i
  sin rigtige rolle, f.eks. til at finde en linje i en checksum-fil.
- **`ca-certificates` og `curl` skal tilføjes til pakkelisten** i
  `Dockerfile.debian`. `curl` henter filen, `ca-certificates` gør at
  HTTPS-forbindelsen til GitHub kan verificeres. `curl` findes i den kørende
  container i dag, men står ikke i `Dockerfile.debian`, så man kan ikke regne
  med den under build.
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

Udkast. Det er ikke bygget endnu og skal afprøves, før det kommer i artiklen:

```dockerfile
# tilføj til pakkelisten på linje 10-15: ca-certificates, curl

# indsættes efter linje 18 og før USER $USERNAME på linje 27
ARG TASK_VERSION=<slå op>
RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_${ARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin task
```

## Disposition

Output markeret _(afprøvet)_ er kørt i den nuværende container og kan bruges
direkte. Resten skal afprøves efter rebuild.

### 1. Indledning

- Hvad Task er, i to sætninger, og hvorfor det er rart at have i sin devcontainer.
- De tre spørgsmål artiklen besvarer.
- Ændringen i `Dockerfile.debian` vist med det samme.

### 2. Hvor lander de filer, vi downloader?

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
- Build kontra kørsel: filer hentet i `Dockerfile.debian` er bagt ind i dit
  image. Filer hentet i terminalen bagefter ligger kun i den kørende container
  og forsvinder ved rebuild.

Mulig udvidelse: variant med checksum, hvor `grep` finder den rigtige linje i
`task_checksums.txt`, og `sha256sum -c` kontrollerer arkivet.

### 3. Hvor skal programmet installeres?

- Start med konventionen: `/usr/bin` tilhører package manageren,
  `/usr/local/bin` tilhører den, der administrerer maskinen. De blander sig
  ikke i hinandens mapper.

  | | `/usr/bin` | `/usr/local/bin` |
  | --- | --- | --- |
  | Hvem lægger filer der | `apt-get` / `dpkg` | os selv, her via `Dockerfile.debian` |
  | Hvem holder styr på indholdet | package manageren kender hver fils pakke | ingen, det er vores ansvar |
  | Opdatering og fjernelse | `apt-get upgrade` / `apt-get remove` | ny version hentes, eller filen slettes, manuelt |
  | Hvem kan bruge programmerne | alle | alle |

- Reglerne, læseren skal kende:
  - Læg aldrig selv filer i `/usr/bin`. Package manageren regner med at eje
    mappen og kan overskrive filen ved næste opdatering.
  - Debian-pakker må ikke lægge programmer i `/usr/local` (Debians policy), så
    `apt-get` rører aldrig det, vi lægger der.
  - `/usr/local/bin` står før `/usr/bin` i `PATH` med vilje: vores egen version
    vinder over den fra en pakke. Bind det sammen med navnesammenfaldet med
    `taskwarrior`.
  - `bin` er almindelige programmer, `sbin` er administrationsværktøjer
    (f.eks. `visudo`).
  - `/bin` er på Debian et link til `/usr/bin`. Vis `ls -ld /bin`.
  - Mappen hedder `/usr`, ikke `/user`. Brugernes hjemmemapper ligger i `/home`.
  - Opdelingen kommer fra Filesystem Hierarchy Standard (FHS) og gælder også
    uden for Debian.
- Nævn kort `/opt`: til større programmer, der kommer som en hel mappe.
- Konsekvens for `task`: vi henter den selv fra GitHub, så den hører hjemme i
  `/usr/local/bin`, og opdatering sker ved at ændre `TASK_VERSION` og lave rebuild.
- Mappen ejes af `root` med `drwxr-xr-x` _(afprøvet)_: kun `root` kan skrive,
  alle kan læse og køre.
- Den udpakkede fil får `rwxr-xr-x`, præcis som `git` _(afprøvet)_:

  ```console
  $ ls -l /usr/bin/git
  -rwxr-xr-x 1 root root 4082768 Jul 30  2025 /usr/bin/git
  ```

- `~/.local/bin` er samme idé som `/usr/local/bin`, men kun for én bruger og
  uden behov for `root`.
- Kort om alternativet: Tasks eget install-script med `-b /usr/local/bin`. Nævn
  det, men forklar hvorfor artiklen viser de enkelte trin i stedet.

### 4. Skal vi skifte til `container-user` først?

Nej. Dette afsnit er artiklens vigtigste, fordi det er her, de fleste tager fejl.

- To forskellige "brugere" er i spil:
  - `USER` i `Dockerfile.debian` bestemmer, hvem de efterfølgende `RUN`-linjer
    kører som under build.
  - `"remoteUser": "container-user"` i
    [devcontainer.json](../../.devcontainer/debian/devcontainer.json) bestemmer,
    hvem VS Code og terminalen kører som, når containeren er startet.
- **Vis fejlen med vilje.** Flyt blokken ned efter `USER $USERNAME` og byg.
  `curl` henter fint, men `tar` må ikke skrive _(afprøvet som `container-user`)_:

  ```text
  tar: task: Cannot open: Permission denied
  tar: Exiting with failure status due to previous errors
  ```

  `RUN` returnerer fejlkode 2, og build stopper. Der kommer intet image.
- Flyt blokken op før linje 27, og det virker.
- De tre omveje, og hvorfor vi ikke tager dem:

  | Variant efter `USER $USERNAME` | Virker det? | Ulempe |
  | --- | --- | --- |
  | `sudo tar ... -C /usr/local/bin` | ja, linje 24 giver `sudo` uden password | omvej med samme resultat |
  | `-C ~/.local/bin` | ja, men kun med `mkdir -p` foran, for mappen findes ikke _(afprøvet)_ | kun `container-user` har programmet, og `sudo task` finder det ikke |
  | `USER root`, installér, `USER $USERNAME` | ja | sværere at læse end den rigtige rækkefølge |

- Huskeregel:
  - Alt, der skriver uden for hjemmemappen (`apt-get`, `/usr/local/bin`, `/etc`),
    står før `USER $USERNAME`.
  - Alt, der skriver i hjemmemappen, står efter.
  - `USER $USERNAME` står til sidst, så containeren ikke starter som `root`.
- Fælden, der ikke giver en fejl: mangler `USER $USERNAME` til sidst, starter
  containeren som `root`. `remoteUser` dækker over det i VS Code, men
  `docker compose exec dev zsh` giver så en `root`-shell.

### 5. Hvordan virker `PATH` her?

- `PATH` er en liste af mapper adskilt af `:`. Shell'en leder fra venstre mod
  højre og tager det første match. Vis `echo $PATH | tr ':' '\n'`,
  `command -v task` og `type -a task`.
- Linje 6 i `Dockerfile.debian`:

  ```dockerfile
  PATH="/home/container-user/.local/bin:/usr/local/bin:$PATH"
  ```

  - `$PATH` udfyldes under build med værdien fra `debian:13`, som allerede
    indeholder `/usr/local/bin`. Mappen står der altså to gange _(afprøvet)_.
    Harmløst, men læseren vil se det.
  - `ENV` gælder for alle efterfølgende `RUN`-linjer og for alle processer i
    containeren, uanset bruger.
  - `~/.local/bin` står først, men mappen findes ikke endnu _(afprøvet)_. En
    mappe i `PATH`, der ikke findes, springes bare over. Opretter
    `container-user` den senere og lægger sin egen `task` dér, vinder den over
    den i `/usr/local/bin`.
  - VS Code lægger selv mapper til `PATH` i terminalen _(afprøvet)_.
- Konklusion: `task` virker for `container-user`, fordi `/usr/local/bin` er i
  `PATH`, og det ville det også uden linje 6.
- `PATH` fra `ENV` overlever, når shell'en starter, fordi `/etc/profile` og
  `/etc/zsh/zshenv` kun sætter `PATH`, hvis den er tom _(afprøvet)_.
- Dotfiles installeret med `stow` kan ændre `PATH` i `.zshrc`. Nævn det som det
  første sted at lede, hvis `PATH` ser anderledes ud end her.

### 6. Kontrast: programmer installeret med `apt-get`

- `apt-get` ændrer aldrig `PATH`. Pakken bestemmer selv, hvor filerne lægges,
  og det er altid i mapper, som allerede er i `PATH` _(afprøvet)_:

  ```console
  $ dpkg -L stow | grep bin/
  /usr/bin/chkstow
  /usr/bin/stow
  ```

- `apt-get` kan kun køre som `root`. Som `container-user` _(afprøvet)_:

  ```text
  E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)
  E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), are you root?
  ```

- Der findes ingen installation "kun for `container-user`" med `apt-get`:

  | Hvem kører kommandoen | Hvor | Filen lander i | Ejer | Hvem kan bruge det |
  | --- | --- | --- | --- | --- |
  | `root` | `RUN apt-get install` i `Dockerfile.debian` | `/usr/bin` | `root` | alle |
  | `container-user` | `sudo apt-get install` i terminalen | `/usr/bin` | `root` | alle |

- Forskellen på de to brugere er altså ikke, hvor programmet ligger, men
  hvilken `PATH` de leder med. `sudo` skifter `PATH` ud med `secure_path` fra
  `/etc/sudoers` _(afprøvet)_:

  ```text
  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  ```

  | Programmet ligger i | `container-user` | `sudo ...` |
  | --- | --- | --- |
  | `/usr/bin` (fra `apt-get`) | ja | ja |
  | `/usr/local/bin` (f.eks. `task`) | ja | ja |
  | `~/.local/bin` | ja | nej, `command not found` |

- At _måtte_ køre og at _finde_ er to ting _(afprøvet med et script ejet af
  `container-user`)_:
  - `root` må køre en fil med `rwx------`, selv om den tilhører en anden bruger.
  - Uden en eneste execute-bit (`rw-------`) afvises også `root`.
  - `sudo hej` giver `command not found`, når mappen kun står i brugerens
    `PATH`. `sudo /fuld/sti/hej` virker.
- Pointen: i `/usr/local/bin` opfører `task` sig som et program fra `apt-get`,
  selv om vi har hentet det selv.

### 7. Afprøvning

Efter rebuild, i terminalen i din devcontainer:

```bash
whoami                 # container-user
command -v task        # /usr/local/bin/task
ls -l /usr/local/bin/task
task --version
sudo task --version    # virker også via secure_path
```

Slut med en minimal `Taskfile.yml` og `task --list`, så læseren ser det virke.

### 8. Opsummering

Tre sætninger, én pr. spørgsmål fra indledningen, plus huskereglen fra afsnit 4.

## Arbejdsrækkefølge

1. Slå aktuel version og de præcise filnavne op på releases-siden.
2. Tilføj blokken til `Dockerfile.debian`, rebuild, og kør afprøvningen i afsnit 7.
3. Byg én gang med blokken efter `USER $USERNAME`, og gem fejlen fra build til afsnit 4.
4. Skriv artiklen med rigtigt output.
5. Tilføj nye ord til cSpell (bl.a. `dpkg`), og kør markdownlint.

## Åbne spørgsmål

- Skal checksum-kontrol være med i hovedforløbet eller kun som udvidelse?
- Skal artiklen også vise installation fra terminalen (uden rebuild) som
  kontrast til installation i `Dockerfile.debian`?
