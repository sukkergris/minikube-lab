# Locale i devcontaineren

_Hvorfor `Dockerfile.debian` kører `locale-gen`_

## Ændringen

[`.devcontainer/debian/Dockerfile.debian`](../../.devcontainer/debian/Dockerfile.debian):

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ..."
    locales \
    ...
    && rm -fr /var/lib/apt/lists/* \
    && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen
```

De to sidste linjer er nye.

## Problemet

Dockerfilen sætter `ENV LANG=en_US.UTF-8` og installerer pakken `locales`, men
det er ikke nok. På Debian indeholder `locales`-pakken kun _værktøjerne og
kildedata_. Selve localen skal genereres, før programmer kan bruge den.

Hvilke locales der genereres, styres af `/etc/locale.gen`. I et frisk Debian-image
er alle linjer udkommenterede:

```text
# en_US.UTF-8 UTF-8
```

Uden genereret locale peger `LANG` på noget, der ikke findes. glibc falder så
tilbage til `C`-localen, og programmer klager. Det så sådan ud, hver gang
`stow` (som er skrevet i Perl) kørte i dotfiles' `.install.sh`:

```text
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
 ...
 LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
```

Ud over støjen i loggen betyder `C`-localen, at tegn uden for ASCII kan blive
håndteret forkert. Det rammer fx Powerlevel10k-prompten (ikoner og
specialtegn) og danske bogstaver som æ, ø og å i terminalen.

## Løsningen

1. `sed` fjerner `#` foran `en_US.UTF-8 UTF-8` i `/etc/locale.gen`, så localen
   bliver valgt.
2. `locale-gen` genererer de valgte locales til
   `/usr/lib/locale/locale-archive`.

Det sker i samme `RUN` som installationen af `locales`, så det ligger i ét
image-lag og bliver cachet sammen med pakkerne.

`ENV LANG=en_US.UTF-8` står længere nede i Dockerfilen. Det er fint:
`locale-gen` har ikke brug for `LANG`. Den læser kun `/etc/locale.gen`.

## Sådan tjekker du det

Inde i containeren:

```sh
locale -a        # skal indeholde en_US.utf8
perl -e 1        # må ikke give locale-advarsler
```

## Alternativer

- **`localedef -i en_US -f UTF-8 en_US.UTF-8`**: genererer localen direkte
  uden at redigere `/etc/locale.gen`. Virker lige så godt, men er ikke den
  Debian-idiomatiske måde.
- **`C.UTF-8`**: er indbygget i Debian og kræver hverken `locales`-pakken eller
  `locale-gen`. Den giver UTF-8, men ingen sprog- og landeregler (sortering,
  datoformater osv.). Hvis du kun har brug for UTF-8, kan du bruge
  `ENV LANG=C.UTF-8` og fjerne `locales` fra Dockerfilen.
