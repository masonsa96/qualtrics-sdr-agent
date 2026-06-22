#!/bin/bash
# SessionStart hook: prepare the environment for the last30days skill.
# Web sessions only. Idempotent and non-interactive.
set -euo pipefail

# Only run in Claude Code on the web; local machines already have their own setup.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Resolve a Python >=3.12 interpreter (same requirement as the skill engine).
PY=""
for c in python3.14 python3.13 python3.12 python3; do
  command -v "$c" >/dev/null 2>&1 || continue
  "$c" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 12) else 1)' 2>/dev/null || continue
  PY="$c"; break
done

if [ -z "$PY" ]; then
  echo "last30days setup: no Python >=3.12 found; skill engine will not run." >&2
  exit 0
fi

# Install yt-dlp (YouTube source). pypi is reachable through the web proxy.
# The skill locates yt-dlp via shutil.which(), so it must land on PATH.
if ! command -v yt-dlp >/dev/null 2>&1; then
  "$PY" -m pip install --quiet --disable-pip-version-check --no-input yt-dlp || \
    echo "last30days setup: yt-dlp install failed; YouTube source will be unavailable." >&2
fi

# Make sure pip's user bin dir is on PATH for this and future tool calls.
USER_BIN="$("$PY" -c 'import site,sys,os; print(os.path.join(site.getuserbase(),"bin"))' 2>/dev/null || true)"
if [ -n "$USER_BIN" ] && [ -d "$USER_BIN" ] && [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  case ":$PATH:" in
    *":$USER_BIN:"*) ;;
    *) echo "export PATH=\"$USER_BIN:\$PATH\"" >> "$CLAUDE_ENV_FILE" ;;
  esac
fi

echo "last30days setup complete (python=$PY, yt-dlp=$(command -v yt-dlp 2>/dev/null || echo missing))."
