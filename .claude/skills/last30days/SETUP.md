# last30days — Setup & Usage

How to run the `last30days` research skill bundled in this repo.

## Invoke it

In Claude Code (CLI, desktop, or web for this repo), type the slash command with a topic:

```
/last30days nvidia earnings reaction
/last30days AI video tools
/last30days OpenAI vs Anthropic        # "vs" triggers comparison mode
```

Claude reads `SKILL.md`, runs the engine (`scripts/last30days.py`) across Reddit /
Hacker News / Polymarket / YouTube / etc., and returns a synthesized briefing with a
`🌐 last30days` badge and a sources footer.

## Requirements

| Need | Detail | Install |
|------|--------|---------|
| Python ≥ 3.12 | engine runtime | usually preinstalled |
| Node ≥ 22 | vendored X (`bird-search`) client | only for X via cookies |
| `yt-dlp` on PATH | YouTube source | `pip install yt-dlp` |

Python deps are **stdlib only** — there is no `requirements.txt` to install.
`bird-search` has **no npm dependencies**.

On Claude Code **web** sessions, `.claude/hooks/session-start.sh` installs `yt-dlp`
automatically. On a **local** machine, run `pip install yt-dlp` yourself if you want
the YouTube source.

## Sources & optional keys

Free, no key required: **Reddit, Hacker News, Polymarket**, and **YouTube** (needs `yt-dlp`).

Set any of these env vars before launching Claude to unlock more sources (all optional):

| Source | Env var(s) | Where |
|--------|-----------|-------|
| TikTok / Instagram | `SCRAPECREATORS_API_KEY` | scrapecreators.com (100 free credits) |
| X / Twitter | `XAI_API_KEY`, or `AUTH_TOKEN` + `CT0` cookies | api.x.ai, or x.com browser cookies |
| Bluesky | `BSKY_HANDLE` + `BSKY_APP_PASSWORD` | bsky.app/settings/app-passwords |
| Web-search backend | `BRAVE_API_KEY` / `PARALLEL_API_KEY` / `OPENROUTER_API_KEY` | respective providers |

Example (local):

```bash
export SCRAPECREATORS_API_KEY=sk_...
claude            # then type: /last30days <topic>
```

## Network access (important for web sessions)

The engine fetches live data over the network. In a Claude Code **web** environment,
outbound traffic is governed by the environment's network policy. The skill's data
domains must be allowed or every source returns `403` and the briefing comes back
`Sources: none`.

Domains to allow:

- `www.reddit.com`, `reddit.com`
- `hn.algolia.com`
- `gamma-api.polymarket.com`
- `www.youtube.com`, `youtube.com` (YouTube via yt-dlp)
- keyed sources: `api.scrapecreators.com`, `api.x.ai`, `x.com`, `api.openai.com`,
  `openrouter.ai`, `api.search.brave.com`

See https://code.claude.com/docs/en/claude-code-on-the-web for changing the policy.
On a local machine this does not apply — you have normal internet.

## Verify without network

```bash
cd .claude/skills/last30days
python3.12 scripts/last30days.py --diagnose                    # shows active sources/keys
python3.12 scripts/last30days.py "demo" --mock --emit=compact  # runs the full pipeline on fixtures
```
