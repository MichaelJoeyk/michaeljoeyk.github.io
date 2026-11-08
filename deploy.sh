#!/usr/bin/env bash
# Deployt alle Apps und die Startseite nach GitHub Pages (michaeljoeyk.github.io).
# Aufruf: ./deploy.sh [--dry-run] [--force]
#   --dry-run  nur anzeigen, was deployt würde
#   --force    auch Apps deployen, die schon aktuell sind
# Deployt wird nur, was committet und nach Forgejo (origin) gepusht ist.
set -uo pipefail

DEV="$(cd "$(dirname "$0")/.." && pwd)"
START="$DEV/sixt-apps-startseite"
SITE_URL="https://michaeljoeyk.github.io"
GH_OWNER="MichaelJoeyk"
export PATH="$HOME/.local/opt/node/bin:$HOME/.local/opt/node-v26.13.0-linux-x64/bin:$PATH"
source "$START/apps.sh"

DRY=0; FORCE=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    --force) FORCE=1 ;;
    *) echo "Aufruf: $0 [--dry-run] [--force]" >&2; exit 1 ;;
  esac
done

fehler=0
deployt=()   # "<pfad>:<hash>" der deployten Apps, werden am Ende live geprüft
start_neu=""  # Commit der Startseite, falls gepusht

# Bricht für ein Repo ab, wenn etwas uncommittet oder nicht auf Forgejo ist.
sauber() {
  local dir="$1"
  if [ -n "$(git -C "$dir" status --porcelain)" ]; then
    echo "   ✗ uncommittete Änderungen, übersprungen"; return 1
  fi
  git -C "$dir" fetch -q origin || { echo "   ✗ Forgejo nicht erreichbar, übersprungen"; return 1; }
  local vor; vor=$(git -C "$dir" rev-list --count '@{u}..HEAD' 2>/dev/null) || { echo "   ✗ kein Upstream-Branch, übersprungen"; return 1; }
  if [ "$vor" -gt 0 ]; then
    echo "   ✗ $vor Commit(s) nicht nach Forgejo gepusht, übersprungen"; return 1
  fi
}

# Prüft, ob der Commit-Hash im ausgelieferten JS der App steckt (vite.config.js baut ihn als __GIT_HASH__ ein).
live_aktuell() {
  local path="$1" hash="$2" js
  js=$(curl -fsS "$SITE_URL/$path/" | grep -oE 'assets/index-[^"]+\.js' | head -1) || return 1
  [ -n "$js" ] || return 1
  # erst komplett laden, sonst bricht curl bei grep -q ab und pipefail meldet Fehler
  local inhalt; inhalt=$(curl -fsS "$SITE_URL/$path/$js") || return 1
  grep -qF "\"$hash\"" <<<"$inhalt"
}

for entry in "${APPS[@]}"; do
  dir="$DEV/${entry%%:*}"; path="${entry##*:}"
  echo "== $path"
  [ -d "$dir" ] || { echo "   ✗ Ordner $dir fehlt"; fehler=1; continue; }
  sauber "$dir" || { fehler=1; continue; }
  hash=$(git -C "$dir" rev-parse --short HEAD)
  if [ "$FORCE" = 0 ] && live_aktuell "$path" "$hash"; then
    echo "   ✓ live aktuell ($hash)"; continue
  fi
  if [ "$DRY" = 1 ]; then echo "   → würde $hash deployen"; continue; fi
  echo "   → deploye $hash"
  if (cd "$dir" && npm run deploy --silent >/dev/null 2>&1); then
    deployt+=("$path:$hash")
  else
    echo "   ✗ npm run deploy fehlgeschlagen (Details: cd $dir && npm run deploy)"; fehler=1
  fi
done

echo "== Startseite"
if sauber "$START"; then
  lokal=$(git -C "$START" rev-parse HEAD)
  live=$(git -C "$START" ls-remote github main | cut -f1)
  if [ "$lokal" = "$live" ]; then
    echo "   ✓ live aktuell ($(git -C "$START" rev-parse --short HEAD))"
  elif [ "$DRY" = 1 ]; then
    echo "   → würde $(git -C "$START" rev-parse --short HEAD) nach GitHub pushen"
  elif git -C "$START" push -q github main; then
    echo "   → nach GitHub gepusht"; start_neu="$lokal"
  else
    echo "   ✗ Push nach GitHub fehlgeschlagen"; fehler=1
  fi
else
  fehler=1
fi

# Warten, bis der neue Stand wirklich ausgeliefert wird (Pages-Build dauert meist unter einer Minute).
if [ "${#deployt[@]}" -gt 0 ] || [ -n "$start_neu" ]; then
  echo "== Warte, bis GitHub Pages den neuen Stand ausliefert"
  for item in "${deployt[@]}"; do
    path="${item%%:*}"; hash="${item##*:}"; ok=0
    for _ in $(seq 1 36); do live_aktuell "$path" "$hash" && { ok=1; break; }; sleep 5; done
    if [ "$ok" = 1 ]; then echo "   ✓ $path ($hash)"; else echo "   ✗ $path: nach 3 Minuten noch nicht live"; fehler=1; fi
  done
  if [ -n "$start_neu" ]; then
    ok=0
    for _ in $(seq 1 36); do
      read -r commit status < <(gh api "repos/$GH_OWNER/michaeljoeyk.github.io/pages/builds/latest" --jq '"\(.commit) \(.status)"' 2>/dev/null)
      [ "$commit" = "$start_neu" ] && [ "$status" = built ] && { ok=1; break; }
      sleep 5
    done
    if [ "$ok" = 1 ]; then echo "   ✓ Startseite (${start_neu:0:7})"; else echo "   ✗ Startseite: Build nach 3 Minuten nicht fertig"; fehler=1; fi
  fi
fi

[ "$fehler" = 0 ] && echo "Fertig." || { echo "Fertig, aber mit Fehlern (siehe ✗)."; exit 1; }
