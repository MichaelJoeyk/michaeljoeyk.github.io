#!/usr/bin/env bash
# Testumgebung: Startseite + drei Apps unter einer Adresse, wie auf GitHub Pages.
# Aufruf: ./testenv.sh [up|down|status]   (Standard: up)
set -euo pipefail

PORT="${PORT:-8090}"
DEV="$(cd "$(dirname "$0")/.." && pwd)"
START="$DEV/sixt-apps-startseite"
SITE="${XDG_STATE_HOME:-$HOME/.local/state}/sixt-testenv"
PIDFILE="$SITE.pid"
export PATH="$HOME/.local/opt/node/bin:$HOME/.local/opt/node-v26.13.0-linux-x64/bin:$PATH"

# Ordner im Repo-Verzeichnis -> Pfad auf der Testseite
APPS=("kennzeichenschilder-app:kennzeichenschilder" "acriss-check:acriss-check" "fuehrerschein-check:fuehrerschein-check")

running() { [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; }

case "${1:-up}" in
  down)
    if running; then kill "$(cat "$PIDFILE")"; rm -f "$PIDFILE"; echo "gestoppt"; else echo "lief nicht"; fi
    ;;
  status)
    if running; then echo "läuft auf Port $PORT (PID $(cat "$PIDFILE"))"; else echo "gestoppt"; fi
    ;;
  up)
    rm -rf "$SITE.new"; mkdir -p "$SITE.new"
    cp -r "$START"/{index.html,style.css,theme.js,favicon.svg,site.webmanifest,assets} "$SITE.new/"
    for entry in "${APPS[@]}"; do
      dir="${entry%%:*}"; path="${entry##*:}"
      [ -d "$DEV/$dir" ] || git clone -q "git@git.lan:ba/$dir.git" "$DEV/$dir"
      echo "== Build $dir"
      (cd "$DEV/$dir" && { [ -d node_modules ] || npm ci --silent; } && npx vite build --logLevel warn)
      cp -r "$DEV/$dir/dist" "$SITE.new/$path"
    done
    rm -rf "$SITE"; mv "$SITE.new" "$SITE"   # Server liefert danach den neuen Stand
    if ! running; then
      (cd "$SITE" && setsid nohup python3 -m http.server "$PORT" --bind 0.0.0.0 >/dev/null 2>&1 </dev/null & echo $! > "$PIDFILE") >/dev/null 2>&1
      sleep 1
    fi
    echo "Startseite:  http://claude.lan:$PORT/"
    for entry in "${APPS[@]}"; do echo "             http://claude.lan:$PORT/${entry##*:}/"; done
    ;;
  *) echo "Aufruf: $0 [up|down|status]" >&2; exit 1 ;;
esac
