# Testumgebung

**Ziel/Isolation:** Startseite und die vier Apps laufen unter einer Adresse wie auf GitHub Pages (gleicher Ursprung, also gemeinsame Theme-Einstellung). Kein Docker, kein Prod-Zugriff, nichts davon ist produktiv.

| Pfad | Quelle |
|---|---|
| `/` | dieses Repo (`index.html`, `style.css`, …) |
| `/schluesselanhaenger/` | `~/dev/schluesselanhaenger-app` (wird bei Bedarf geklont) |
| `/kennzeichenschilder/` | Weiterleitung aus diesem Repo (`kennzeichenschilder/index.html`) |
| `/acriss-check/` | `~/dev/acriss-check` |
| `/acriss-liste/` | `~/dev/acriss-liste` |
| `/fuehrerschein-check/` | `~/dev/fuehrerschein-check` |

## Anlegen/Aktualisieren
```bash
just test      # = ./testenv.sh, baut die vier Apps (vite build), setzt die Seite zusammen, startet den Server
```
Erneut ausführen übernimmt Änderungen (Apps werden neu gebaut, der Server läuft weiter).

## Zugriff
`http://claude.lan:8090/` (Port per `PORT=… ./testenv.sh` änderbar). Gebaut wird nach `~/.local/state/sixt-testenv/`.

## Status / Abbauen
```bash
just test-status
just test-stop
```

## Reset
`./testenv.sh down && rm -rf ~/.local/state/sixt-testenv && ./testenv.sh`

Die Apps nutzen `base: './'`, deshalb funktionieren die Unterpfade ohne Anpassung. Der Server läuft bis zum nächsten LXC-Neustart.
