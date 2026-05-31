#!/usr/bin/env bash
# Cycles through random wallpapers from $WALLPAPER_DIRS every $INTERVAL seconds
# using awww (a swww fork). Run from Hyprland autostart.
# WALLPAPER_DIRS: colon-separated list of directories (e.g. ~/walls:~/extra-walls)
# Falls back to $WALLPAPER_DIR for backward compatibility.

set -euo pipefail
WALLPAPER_DIRS="$HOME/backup/wallpapers_grok/wallpapers:$HOME/Projects/wallpaper"
WALLPAPER_DIRS="${WALLPAPER_DIRS:-${WALLPAPER_DIR:-$HOME/Projects/wallpaper}}"
INTERVAL="${INTERVAL:-60}"
TRANSITION="${TRANSITION:-fade}"

# Make sure the daemon is up before we start sending images.
if ! awww query >/dev/null 2>&1; then
    awww-daemon &
    # Wait for the socket to come alive.
    until awww query >/dev/null 2>&1; do sleep 0.5; done
fi

# Split colon-separated dirs, expand ~, validate each.
IFS=':' read -ra _dirs <<< "$WALLPAPER_DIRS"
valid_dirs=()
for d in "${_dirs[@]}"; do
    d="${d/#\~/$HOME}"
    if [[ -d "$d" ]]; then
        valid_dirs+=("$d")
    else
        echo "random-wallpaper: directory not found (skipped): $d" >&2
    fi
done

if [[ ${#valid_dirs[@]} -eq 0 ]]; then
    echo "random-wallpaper: no valid directories in WALLPAPER_DIRS=$WALLPAPER_DIRS" >&2
    exit 1
fi

LAST_FILE="${XDG_RUNTIME_DIR:-/tmp}/random-wallpaper.last"

set_random() {
    # Collect supported image files from all dirs (null-delimited to handle spaces).
    mapfile -d '' -t wallpapers < <(
        find "${valid_dirs[@]}" -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
               -o -iname '*.gif' -o -iname '*.webp' -o -iname '*.bmp' \) \
            -print0
    )

    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        echo "random-wallpaper: no images found in: ${valid_dirs[*]}" >&2
        return 1
    fi

    local last=""
    [[ -f "$LAST_FILE" ]] && last="$(<"$LAST_FILE")"

    # Pick a random one, avoiding an immediate repeat when possible.
    local pick="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
    if [[ ${#wallpapers[@]} -gt 1 ]]; then
        while [[ "$pick" == "$last" ]]; do
            pick="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
        done
    fi

    printf '%s' "$pick" >"$LAST_FILE"
    awww img "$pick" --transition-type "$TRANSITION"
}

# `once` / `next` switches to a single random wallpaper and exits (for keybinds).
if [[ "${1:-}" == "once" || "${1:-}" == "next" ]]; then
    set_random
    exit $?
fi

while true; do
    set_random || true
    sleep "$INTERVAL"
done
