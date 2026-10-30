# Start Next Menu (eigene Fork)

KDE Plasma 6 Applet – ein Start-Menü im Stil von Start11v2 / Windows-12-Konzept.
Basiert auf [zayronxio/Start.Next](https://github.com/zayronxio/Start.Next) (GPL-3.0+), lokal angepasst.

## Workflow

- Alle Änderungen laufen direkt auf `main` (keine Feature-Branches).
- Repo: `~/Projekte/start-next-menu/`
- Aktives Plasmoid: `~/.local/share/plasma/plasmoids/Start.Next.Menu/`

Änderungen deployen und sichern:

```bash
# 1. Plasmoid-Ordner aktualisieren
cp -r ~/Projekte/start-next-menu/contents/. ~/.local/share/plasma/plasmoids/Start.Next.Menu/contents/

# 2. Plasma neu laden
kquitapp6 plasmashell; sleep 2; kstart6 plasmashell

# 3. Commit + Push auf main
cd ~/Projekte/start-next-menu && git add -A && git commit -m "..." && git push
```

## Installation

In den Plasma-Ordner kopieren:

```bash
cp -r . ~/.local/share/plasma/plasmoids/Start.Next.Menu
```

Danach Plasma neu starten (z. B. `kquitapp6 plasmashell && kstart6 plasmashell` oder einfach ausloggen).

Danach das Applet „Start Next Menu" über den Desktop-Hintergrund → Panel-Widget hinzufügen einbauen.
