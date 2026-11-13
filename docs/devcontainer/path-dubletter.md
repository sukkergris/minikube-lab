# Dubletter i PATH

_Hvorfor `echo $PATH` viser de samme stier flere gange, og hvordan du fjerner dem_

## Symptomet

I en terminal i VS Code ser PATH sådan ud (her er hver sti sat på sin egen linje):

```text
/home/container-user/.local/bin
/vscode/vscode-server/bin/linux-x64/<commit>/bin/remote-cli
/home/container-user/.local/bin
/home/container-user/.local/bin
/usr/local/bin
/usr/local/sbin
/usr/local/bin
/usr/sbin
/usr/bin
/sbin
/bin
/Applications/Visual Studio Code.app/Contents/Resources/app/bin
/home/container-user/.dotnet/tools
/home/container-user/.vscode-server/data/User/globalStorage/github.copilot-chat/debugCommand
/vscode/vscode-server/bin/linux-x64/<commit>/bin/copilot-shim
/Applications/Visual Studio Code.app/Contents/Resources/app/bin
/home/container-user/.dotnet/tools
```

`~/.local/bin` står der tre gange, `/usr/local/bin` to gange, og macOS-stien og
`~/.dotnet/tools` to gange hver.

## Hvor hver del kommer fra

| Del af PATH                                             | Kilde                                       |
| ------------------------------------------------------- | ------------------------------------------- |
| `~/.local/bin`                                          | `~/.zshrc`, 2. kørsel                       |
| `.../bin/remote-cli`                                    | VS Code-terminalen                          |
| `~/.local/bin`                                          | `~/.zshrc`, 1. kørsel                       |
| `~/.local/bin:/usr/local/bin`                           | `ENV PATH=` i `Dockerfile.debian`           |
| `/usr/local/sbin:/usr/local/bin:/usr/sbin:...:/bin`     | Standard-PATH fra `debian:13`               |
| `/Applications/...:~/.dotnet/tools`                     | `~/.zshrc`, 1. kørsel                       |
| `copilot-chat/debugCommand`, `copilot-shim`             | VS Code extensions (Copilot)                |
| `/Applications/...:~/.dotnet/tools`                     | `~/.zshrc`, 2. kørsel                       |

Der er tre grunde til dubletterne.

### 1. `.zshrc` kører to gange

`~/.zshrc` kommer fra dotfiles (symlink til `~/dotfiles/zsh/.zshrc`) og
indeholder:

```zsh
export PATH="$HOME/.local/bin:$PATH"                                            # foran
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"  # bagved
export PATH="$PATH:$HOME/.dotnet/tools"                                         # bagved
```

Når VS Code server starter, kører den først din login shell (`zsh -il`) for at
aflæse dit miljø. Her kører `.zshrc` første gang, og VS Code gemmer den PATH,
der kommer ud af det.

Når du åbner en terminal, starter VS Code en ny interaktiv zsh, der arver den
gemte PATH. `.zshrc` kører igen og lægger de samme stier til en gang mere: én
foran og to bagved. VS Code og Copilot har i mellemtiden indsat deres egne stier,
og derfor ligger dubletterne ikke lige ved siden af hinanden.

### 2. Dockerfile gentager standardstier

[`.devcontainer/debian/Dockerfile.debian`](../../.devcontainer/debian/Dockerfile.debian):

```dockerfile
ENV PATH="/home/container-user/.local/bin:/usr/local/bin:$PATH"
```

`/usr/local/bin` står allerede i Debians standard-PATH, så den kommer med to
gange. `~/.local/bin` bliver også tilføjet af `.zshrc`.

### 3. En macOS-sti fra dotfiles

`/Applications/Visual Studio Code.app/...` findes kun på Mac. I din devcontainer
gør den ingenting, men den fylder i PATH.

## Er det et problem?

Ikke funktionelt. Shell bruger den første sti, hvor kommandoen findes, så
dubletter ændrer ikke, hvilket program der bliver kørt. Men det gør PATH sværere
at læse og fejlsøge.

## Løsning

### Fjern dubletter i zsh

Sæt denne linje øverst i `.zshrc` i dotfiles:

```zsh
typeset -U path PATH
```

I zsh er `path` et array, der er bundet til `PATH`. `-U` gør arrayet unikt:
hver gang PATH ændres, fjerner zsh dubletter og beholder den første forekomst.
Rækkefølgen bevares, og resten af `.zshrc` kan blive som den er.

### Valgfri oprydning

Tilføj kun macOS-stien på Mac:

```zsh
[[ "$OSTYPE" == darwin* ]] && path+=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin")
```

Fjern `/usr/local/bin` fra `ENV PATH` i Dockerfile, fordi base image allerede
har den:

```dockerfile
ENV PATH="/home/container-user/.local/bin:$PATH"
```

`~/.local/bin` skal blive stående i Dockerfile. Den er nødvendig for
processer, der ikke starter via zsh, fx `postCreateCommand`, som kører med
`bash`.

Rør ikke ved `remote-cli`- og Copilot-stierne. Dem styrer VS Code selv.

## Tjek resultatet

Genstart terminalen og vis PATH med én sti per linje:

```sh
print -l $path
```

Find eventuelle tilbageværende dubletter:

```sh
print -l $path | sort | uniq -d
```

Tomt output betyder ingen dubletter.
