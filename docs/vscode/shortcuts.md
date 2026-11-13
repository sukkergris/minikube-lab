# Genveje i VS Code med VSCodeVim

Tabs, editor groups og hvorfor Ctrl-genveje driller på Linux.

## Hvorfor virker Ctrl+W og Ctrl+P ikke?

Extension'en **VSCodeVim** (`vscodevim.vim`) tager en række Ctrl-taster, når
fokus er i en tekst-editor. På Mac giver det ingen konflikt, fordi VS Code
bruger Cmd og Vim bruger Ctrl. På Linux bruger begge Ctrl:

| Handling                   | Mac    | Linux      |
| -------------------------- | ------ | ---------- |
| VS Code: søg fil           | Cmd+P  | **Ctrl+P** |
| VS Code: luk fane          | Cmd+W  | **Ctrl+W** |
| Vim: forrige linje/forslag | Ctrl+P | **Ctrl+P** |
| Vim: vindueskommandoer     | Ctrl+W | **Ctrl+W** |

### Løsning

Giv de ønskede taster tilbage til VS Code i _User_ settings
(`Preferences: Open User Settings (JSON)`) på værtsmaskinen:

```json
"vim.handleKeys": {
  "<C-w>": false,
  "<C-p>": false
}
```

Med `"<C-w>": false` holder `Ctrl+W h/l/q/c/o` op med at virke. Kolon-kommandoer
og `ZZ`/`ZQ` virker stadig.

Alternativt giver `"vim.useCtrlKeys": false` alle Ctrl-genveje tilbage til VS
Code, men så mister du også Vim's Ctrl-kommandoer (Ctrl+D/U, Ctrl+V, Ctrl+R).

### Find selv ud af, hvem der tager en tast

1. Kør `Developer: Toggle Keyboard Shortcuts Troubleshooting`.
2. Tryk tasten.
3. Se i **Output**, hvilken kommando der blev kørt (`matched ...`).

Almindelige bogstaver som `g` og `t` vises altid som "no keybinding entries",
fordi Vim modtager dem som tekstinput. Det betyder ikke, at de ikke virker.

## Filsøgning med leader-tasten

I stedet for at give Ctrl+P til VS Code kan Vim beholde den, og filsøgningen
(Quick Open) får sin egen leader-genvej: `Space` efterfulgt af `p` i normal
mode.

Tilføj i _User_ settings (`Preferences: Open User Settings (JSON)`) på
værtsmaskinen:

```json
"vim.leader": "<space>",
"vim.normalModeKeyBindingsNonRecursive": [
  {
    "before": ["<leader>", "p"],
    "commands": ["workbench.action.quickOpen"]
  }
]
```

Bemærk:

- **Kør `Developer: Reload Window` efter ændringer.** VSCodeVim opdager ikke
  altid nye mappings, mens den kører. Space bliver fanget, men `p` gør ingenting,
  indtil vinduet er genindlæst.
- **Der må kun være én `vim.normalModeKeyBindingsNonRecursive`.** Står nøglen der
  to gange, vinder den sidste. Saml alle mappings i samme liste.
- **Settings-visningen viser kun "Edit in settings.json"** for denne
  indstilling. Det er normalt for lister med objekter og betyder ikke, at
  indstillingen er ukendt.
- **Bruger du VS Code-profiler,** gælder indstillingen kun i den profil, hvor den
  er gemt. Den aktive profil står på tandhjulet nederst til venstre.
- **Indstillingen hører til på værtsmaskinen,** ikke i projektet eller i
  _Remote [Dev Container]_ settings. VSCodeVim kører lokalt, så den følger med
  i alle projekter og devcontainers.

Uden ekstra opsætning kan filsøgningen også åbnes med `Ctrl+Shift+P`, hvorefter
du sletter `>`.

### Fejlsøgning af Vim-mappings

Tilføj `"vim.debug.loggingLevelForConsole": "debug"` midlertidigt. Loggen havner
ikke i Output-panelet, men i `Developer: Toggle Developer Tools` → **Console**.
Fjern indstillingen igen bagefter.

## Normal mode eller kolon-kommando

Vim har to slags kommandoer:

- **Normal mode-kommandoer** skrives direkte, uden kolon og uden Enter. Fx
  `gt`, `ZZ`, `u`.
- **Kolon-kommandoer** (Ex-kommandoer) starter med `:` og afsluttes med Enter.
  Fx `:tabn`, `:q`.

`:gt` findes ikke. Tryk Esc for at være sikker på at stå i normal mode
(`-- NORMAL --` i statusbaren).

## Luk filer

| Genvej                   | Gør                                         |
| ------------------------ | ------------------------------------------- |
| `:q`                     | Luk filen (advarer, hvis den ikke er gemt)  |
| `:q!` eller `ZQ`         | Luk uden at gemme                           |
| `:wq`, `:x` eller `ZZ`   | Gem og luk                                  |
| `Ctrl+W q` / `Ctrl+W c`  | Luk det aktive split                        |
| `:qa`                    | Luk alle åbne filer                         |
| `:wqa`                   | Gem og luk alle filer                       |
| `:only` eller `Ctrl+W o` | Luk alle andre editor groups                |
| `Ctrl+W` (VS Code)       | Luk fane, hvis `<C-w>` er givet til VS Code |

## Skift mellem tabs

Gælder kun tabs i den editor group, du står i.

| Genvej                           | Gør                                  |
| -------------------------------- | ------------------------------------ |
| `gt` / `gT`                      | Næste / forrige tab (Vim)            |
| `3gt`                            | Gå til tab nummer 3 (Vim)            |
| `:tabn` / `:tabp`                | Næste / forrige tab (Vim)            |
| `Ctrl+PageDown` / `Ctrl+PageUp`  | Næste / forrige tab                  |
| `Ctrl+Tab`                       | Senest brugte tab (hold Ctrl nede)   |
| `Alt+1` … `Alt+9`                | Gå til tab nummer 1–9                |

## Skift mellem editor groups

| Genvej                  | Gør                                  |
| ----------------------- | ------------------------------------ |
| `Ctrl+W h` / `Ctrl+W l` | Gruppen til venstre / højre (Vim)    |
| `Ctrl+W w`              | Næste gruppe (Vim)                   |
| `Ctrl+1`, `Ctrl+2`, …   | Gå til gruppe 1, 2, …                |

## Split og flyt tabs

| Genvej                               | Gør                                        |
| ------------------------------------ | ------------------------------------------ |
| `Ctrl+\`                             | Split editoren (kopi af filen i ny gruppe) |
| `:vsp` / `:vsplit`                   | Samme som `Ctrl+\` (Vim)                   |
| `Ctrl+Alt+→` / `Ctrl+Alt+←`          | Flyt tab til gruppen til højre / venstre   |
| `View: Move Editor into Right Group` | Flyt tab til ny gruppe ved siden af        |
| `View: Move Editor into Group Below` | Flyt tab til ny gruppe nedenunder          |

`Ctrl+\` og `:vsp` laver en kopi. Luk den gamle tab med `:q`, hvis du ville
flytte den. `Ctrl+Alt+→/←` kan være optaget af dit desktop-miljø til at skifte
workspace. De to `View:`-kommandoer køres fra Command Palette (Ctrl+Shift+P)
og kan få deres egen genvej i Keyboard Shortcuts (Ctrl+K Ctrl+S).

## Terminalen

Når terminalen har fokus, går de fleste taster direkte til shell. I zsh sletter
Ctrl+W det forrige ord, og `Ctrl+\` laver en split terminal. Luk en terminal
med `exit`, Ctrl+D eller skraldespandsikonet.
