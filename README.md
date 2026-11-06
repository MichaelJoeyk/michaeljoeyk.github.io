# Tools – Startseite

Statische Einstiegsseite für die drei Web-Apps, gehostet als GitHub-Pages-User-Site unter `https://michaeljoeyk.github.io/`. Optik wie die Apps selbst.

| App | Pfad | Repo |
|---|---|---|
| Kennzeichenschilder | `/kennzeichenschilder/` | `ba/kennzeichenschilder-app` |
| ACRISS-Check | `/acriss-check/` | `ba/acriss-check` |
| Führerschein-Check | `/fuehrerschein-check/` | `ba/fuehrerschein-check` |

Die Apps laufen als eigene GitHub-Projektseiten (Repo-Name = Pfad) und werden dort per `npm run deploy` veröffentlicht. Weil alle auf derselben Domain liegen, teilen sie sich den Dark-/Hellmodus (`localStorage`-Key `theme`).

## Aufbau

| Datei | Inhalt |
|---|---|
| `index.html` | Header, Kacheln, Footer |
| `style.css` | Farben und Bausteine aus den Apps |
| `theme.js` | Theme-Toggle mit Kreis-Reveal |
| `assets/` | Logos der Apps (aus den jeweiligen Repos kopiert) |

## Lokal ansehen

```bash
python3 -m http.server 8090
```

## Deploy

Kein Build. GitHub-Repo `michaeljoeyk.github.io` als Remote `github` eintragen und `main` pushen:

```bash
git remote add github git@github.com:michaeljoeyk/michaeljoeyk.github.io.git
git push github main
```

Pages-Quelle im GitHub-Repo: Branch `main`, Ordner `/`.

## Neue App ergänzen

Kachel in `index.html` kopieren, Logo nach `assets/` legen, Pfad = Name des GitHub-Repos der App.
