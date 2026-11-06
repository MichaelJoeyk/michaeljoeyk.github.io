# Testumgebung

**Ziel/Isolation:** Startseite und die drei Apps laufen unter einer Adresse wie auf GitHub Pages (gleicher Ursprung, also gemeinsame Theme-Einstellung). Kein Docker, kein Prod-Zugriff, nichts davon ist produktiv.

| Pfad | Quelle |
|---|---|
| `/` | dieses Repo (`index.html`, `style.css`, …) |
| `/kennzeichenschilder/` | `~/dev/kennzeichenschilder-app` (wird bei Bedarf geklont) |
| `/acriss-check/` | `~/dev/acriss-check` |
| `/fuehrerschein-check/` | `~/dev/fuehrerschein-check` |

## Anlegen/Aktualisieren
```bash
./testenv.sh        # baut die drei Apps (vite build), setzt die Seite zusammen, startet den Server
```
Erneut ausführen übernimmt Änderungen (Apps werden neu gebaut, der Server läuft weiter).

## Zugriff
`http://claude.lan:8090/` (Port per `PORT=… ./testenv.sh` änderbar). Gebaut wird nach `~/.local/state/sixt-testenv/`.

## Status / Abbauen
```bash
./testenv.sh status
./testenv.sh down
```

## Reset
`./testenv.sh down && rm -rf ~/.local/state/sixt-testenv && ./testenv.sh`

Die Apps nutzen `base: './'`, deshalb funktionieren die Unterpfade ohne Anpassung. Der Server läuft bis zum nächsten LXC-Neustart.
