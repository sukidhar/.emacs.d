# Helix-mode Keybindings (Suki's Centaur Emacs)

Helix is modal: you start in **Normal** state. Keys below are normal-state unless noted.

- `i` / `a` — enter Insert (before / after point)
- `I` / `A` — Insert at start / end of line
- `o` / `O` — open new line below / above
- `Esc` — back to Normal
- `:` — execute Emacs command (`M-x` equivalent)

---

## Movement

| Key | Action |
|---|---|
| `h` `j` `k` `l` | left / down / up / right |
| `w` / `b` / `e` | next word start / prev word / next word end |
| `W` / `B` / `E` | same, long-word (whitespace-delimited) |
| `f<c>` / `t<c>` | find char `<c>` / till char `<c>` (forward) |
| `F<c>` / `T<c>` | same, backward |
| `M-.` | repeat last `f`/`t` |
| `gg` / `ge` | top / bottom of buffer |
| `gh` / `gl` / `gs` | line start / line end / first non-whitespace |
| `G` | go to line N (with count) |
| `1`–`9`,`0` | numeric prefix (count) |
| `C-f` / `C-b` | page down / up |
| `C-d` / `C-u` | half-page down / up (smooth pixel scroll) |

## Selection / Visual

| Key | Action |
|---|---|
| `v` | begin selection |
| `x` | select whole line |
| `%` | select whole buffer |

## Editing

| Key | Action |
|---|---|
| `d` | delete (kill) thing/selection |
| `y` | yank (copy) |
| `p` | paste (yank from kill ring) |
| `c` | change (delete + insert) |
| `r<c>` | replace char with `<c>` |
| `R` | replace with last yank |
| `u` / `U` | undo / redo |
| `<` / `>` | indent left / right |
| `C-c` | comment line |

## Search

| Key | Action |
|---|---|
| `/` | search forward |
| `n` / `N` | next / previous match |

## Goto (`g…`)

| Key | Action |
|---|---|
| `gd` | find definition (xref / lsp) |
| `gr` | find references |
| `gy` | type definition (eglot — limited under lsp-mode) |
| `gi` | implementation (eglot — limited under lsp-mode) |
| `gw` | avy jump to char (custom) |
| `gj` / `gk` | next / previous line |

## View (`z…`)

| Key | Action |
|---|---|
| `zz` | center cursor in window |
| `zt` | scroll cursor to top (custom) |
| `zb` | scroll cursor to bottom (custom) |

## Window (`C-w …`)

| Key | Action |
|---|---|
| `C-w h/j/k/l` | move focus left/down/up/right |
| `C-w w` | next window |
| `C-w v` / `C-w s` | split vertical / horizontal |
| `C-w q` | close window |
| `C-w o` | close other windows |

## Diagnostics

| Key | Action |
|---|---|
| `]d` / `[d` | next / previous flymake error |

---

## SPC Leader (Space)

Press `SPC` in Normal state to open the leader.

### Built-in

| Key | Action |
|---|---|
| `SPC f` | project-find-file |
| `SPC b` | project-switch-to-buffer |
| `SPC j` | project-switch-project |
| `SPC /` | project-find-regexp (ripgrep across project) |
| `SPC a` | eglot code action / quickfix |
| `SPC r` | eglot rename |
| `SPC d` | show buffer diagnostics |

### Custom (configured in `custom-post.el`)

#### `SPC g` — git

| Key | Action |
|---|---|
| `SPC g g` | lazygit (full-frame vterm) |
| `SPC g f` | pick a changed file (modified + untracked) |
| `SPC g c` | gh clone URL/owner-repo into chosen folder, open as project |
| `SPC g b` | toggle inline blamer (GitLens-style ghost text) for current buffer |
| `SPC g l` | git-link (line URL) |
| `SPC g L` | git-link to commit |
| `SPC g h` | git-link homepage |

#### `SPC l` — lsp

| Key | Action |
|---|---|
| `SPC l e` | pick Elixir LSP for project (dexter / next-ls), persists in `.dir-locals.el` |

#### `SPC s` — sql (sqls language server)

| Key | Action |
|---|---|
| `SPC s c` | open `~/.config/sqls/config.yml` (saves reload sqls in live SQL buffers) |
| `SPC s s` | switch active sqls connection |
| `SPC s q` | execute SQL paragraph at point against active connection |

#### `SPC t` — toggle

| Key | Action |
|---|---|
| `SPC t t` | treemacs (current project, exclusive) |
| `SPC t r` | tabspaces restore session |
| `SPC t s` | tabspaces save session |

#### `SPC c` — Claude (claudemacs)

| Key | Action |
|---|---|
| `SPC c c` | start menu |
| `SPC c t` | toggle Claude buffer |
| `SPC c e` | transient menu |
| `SPC c f` | add current file as reference |
| `SPC c a` | ask without context |
| `SPC c k` | kill Claude session |

#### `SPC p` — project

| Key | Action |
|---|---|
| `SPC p p` | project-switch-project |

#### `SPC h` — help / docs

| Key | Action |
|---|---|
| `SPC h h` | devdocs-dwim (lookup, context-aware) |
| `SPC h l` | devdocs-lookup |
| `SPC h i` | devdocs-install (download a docset) |
| `SPC h p` | devdocs-peruse (browse a docset's index) |
| `SPC h g` | consult-gh search-repos |
| `SPC h f` | consult-gh find-file |
| `SPC h G` | pkg.go.dev (xwidget-webkit) |
| `SPC h e` | hexdocs.pm (xwidget-webkit) |
| `SPC h s` | Google search (xwidget-webkit) |
| `SPC h u` | open any URL (xwidget-webkit) |

For the `SPC h G/e/s/u` browser commands: prefix with `C-u` for system browser, `C-u C-u` for eww. Browser buffers open in a half-width side window on the right.

#### `SPC y` / `SPC Y`

| Key | Action |
|---|---|
| `SPC y` | helix-kill-ring-save (region) |
| `SPC Y` | kill-ring-save |

---

## Other custom global bindings

| Key | Action |
|---|---|
| `C-\`` | toggle vterm (project root) |
| `C-~` | toggle vterm with cd to current dir |
| `C-M-7` | transwin toggle (frame transparency) |
| `C-M-8` / `C-M-9` | decrease / increase transparency |

## Insert state

In Insert state, only Helix-defined keys are:

- `Esc` — back to Normal
- `C-u` / `C-d` — half-page scroll (custom)
- `C-\`` / `C-~` — vterm toggle

Everything else falls through to standard Emacs bindings (e.g. `C-y` yank, `C-s` isearch, `M-x`, etc.).

---

## Notes / gotchas

- **Goto bindings under lsp-mode:** `gd` and `gr` work via xref. `gy` and `gi` are bound to eglot commands (`eglot-find-typeDefinition` / `eglot-find-implementation`); use `M-x lsp-find-type-definition` / `lsp-find-implementation` instead, or rebind these to the `lsp-…` versions if you use them often.
- **`SPC f` and `SPC b`** scope to the current project. To find anywhere, use `M-x find-file` or `C-x C-f`.
- **Completion popup** (corfu) bindings: `TAB` next, `S-TAB` previous, `RET` accept, `C-g` dismiss.
