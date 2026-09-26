#!/usr/bin/env python3
"""Scrub AI agent harness data (sessions, caches, telemetry, memories) — keep configs.

Default: dry-run. Builds a dark HTML report in ~/tmp and opens it in the browser.
Run with --delete to actually delete what the report lists.

Usage:
    python3 ai_data_scrub.py            # report only, deletes nothing
    python3 ai_data_scrub.py --delete   # delete after report
    python3 ai_data_scrub.py --no-open  # report without opening browser
    python3 ai_data_scrub.py --check    # tiny self-test

Requires Python 3.8+. macOS and Linux (no Windows). All paths are relative to
$HOME, so it works for any user. Paths that don't exist are skipped silently.
"""

import argparse
import glob
import os
import shutil
import subprocess
import sys
import webbrowser
from datetime import datetime
from pathlib import Path

HOME = Path.home()
TMP = HOME / "tmp"

# ── Catalog ──────────────────────────────────────────────────────────────────
# (harness, path relative to $HOME, category, action, reason)
# Categories: cache | history | data | auth | config
# Action: delete | keep
# '~' glob patterns allowed (e.g. .claude.json.tmp.*). Unknown paths: add them
# here, never delete unlisted paths.

CATALOG = [
    # ── Claude Code ──
    ("Claude Code", ".claude/projects", "history", "delete", "Session transcripts (JSONL) for every project you've used Claude Code in."),
    ("Claude Code", ".claude/sessions", "history", "delete", "Session state files."),
    ("Claude Code", ".claude/history.jsonl", "history", "delete", "Prompt/command history log."),
    ("Claude Code", ".claude/file-history", "history", "delete", "Snapshots of files edited in sessions (undo history)."),
    ("Claude Code", ".claude/plans", "history", "delete", "Saved plan-mode documents."),
    ("Claude Code", ".claude/telemetry", "data", "delete", "Usage telemetry."),
    ("Claude Code", ".claude/backups", "data", "delete", "Auto-backups of settings/projects metadata."),
    ("Claude Code", ".claude/cache", "cache", "delete", "Misc cache; regenerated on next run."),
    ("Claude Code", ".claude/shell-snapshots", "cache", "delete", "Shell environment snapshots."),
    ("Claude Code", ".claude/paste-cache", "cache", "delete", "Cached paste images/content."),
    ("Claude Code", ".claude/session-env", "cache", "delete", "Per-session env records."),
    ("Claude Code", ".claude.json.tmp.*", "cache", "delete", "Litter from interrupted config writes (~50 stale temp files)."),
    ("Claude Code", ".claude/settings.json", "config", "keep", "Your settings — kept."),
    ("Claude Code", ".claude.json", "config", "keep", "Main config (MCP servers, projects list) — kept."),
    ("Claude Code", ".claude.json.backup", "config", "keep", "Config backup — kept."),
    ("Claude Code", ".claude/skills", "config", "keep", "Installed skills — kept."),
    ("Claude Code", ".claude/plugins", "config", "keep", "Installed plugins — kept."),

    # ── Claude Desktop ──
    ("Claude Desktop", "Library/Application Support/Claude/vm_bundles", "cache", "delete", "10 GB of VM images; re-downloaded automatically when needed."),
    ("Claude Desktop", "Library/Application Support/Claude/claude-code", "cache", "delete", "Bundled Claude Code binary; re-fetched by the app."),
    ("Claude Desktop", "Library/Application Support/Claude/claude-code-vm", "cache", "delete", "VM runtime files; re-fetched by the app."),
    ("Claude Desktop", "Library/Application Support/Claude/claude-code-sessions", "history", "delete", "Claude Code sessions launched from desktop."),
    ("Claude Desktop", "Library/Application Support/Claude/local-agent-mode-sessions", "history", "delete", "Local agent mode session data."),
    ("Claude Desktop", "Library/Application Support/Claude/Cache", "cache", "delete", "HTTP/resource cache."),
    ("Claude Desktop", "Library/Application Support/Claude/Code Cache", "cache", "delete", "Electron JS bytecode cache."),
    ("Claude Desktop", "Library/Application Support/Claude/GPUCache", "cache", "delete", "GPU shader cache."),
    ("Claude Desktop", "Library/Application Support/Claude/DawnGraphiteCache", "cache", "delete", "Graphics cache."),
    ("Claude Desktop", "Library/Application Support/Claude/DawnWebGPUCache", "cache", "delete", "Graphics cache."),
    ("Claude Desktop", "Library/Application Support/Claude/VideoDecodeStats", "cache", "delete", "Video stats db."),
    ("Claude Desktop", "Library/Application Support/Claude/Crashpad", "data", "delete", "Crash dumps and reports."),
    ("Claude Desktop", "Library/Application Support/Claude/sentry", "data", "delete", "Error-reporting telemetry."),
    ("Claude Desktop", "Library/Application Support/Claude/IndexedDB", "data", "delete", "App database incl. cached conversations; resyncs on next launch."),
    ("Claude Desktop", "Library/Application Support/Claude/Local Storage", "data", "delete", "Web app local storage."),
    ("Claude Desktop", "Library/Application Support/Claude/Session Storage", "data", "delete", "Web app session storage."),
    ("Claude Desktop", "Library/Application Support/Claude/WebStorage", "data", "delete", "Webview storage."),
    ("Claude Desktop", "Library/Application Support/Claude/blob_storage", "data", "delete", "Blob cache (attachments, files)."),
    ("Claude Desktop", "Library/Application Support/Claude/Shared Dictionary", "data", "delete", "Chromium shared dictionary cache."),
    ("Claude Desktop", "Library/Application Support/Claude/shared_proto_db", "data", "delete", "Chromium proto db."),
    ("Claude Desktop", "Library/Application Support/Claude/SharedStorage", "data", "delete", "Chromium shared storage."),
    ("Claude Desktop", "Library/Application Support/Claude/InterestGroups", "data", "delete", "Chromium ad-interest data."),
    ("Claude Desktop", "Library/Application Support/Claude/DIPS", "data", "delete", "Chromium damping data."),
    ("Claude Desktop", "Library/Application Support/Claude/DIPS-wal", "data", "delete", "Chromium damping data (WAL)."),
    ("Claude Desktop", "Library/Application Support/Claude/Trust Tokens", "data", "delete", "Chromium trust tokens."),
    ("Claude Desktop", "Library/Application Support/Claude/Trust Tokens-journal", "data", "delete", "Chromium trust tokens journal."),
    ("Claude Desktop", "Library/Application Support/Claude/TransportSecurity", "data", "delete", "HSTS cache; rebuilt automatically."),
    ("Claude Desktop", "Library/Application Support/Claude/Network Persistent State", "data", "delete", "Network state; rebuilt automatically."),
    ("Claude Desktop", "Library/Application Support/Claude/File System", "data", "delete", "Web app file-system storage."),
    ("Claude Desktop", "Library/Application Support/Claude/Partitions", "data", "delete", "Webview partitions — may sign you out of embedded webviews; they re-auth on demand."),
    ("Claude Desktop", "Library/Application Support/Claude/fcache", "cache", "delete", "Fetch cache."),
    ("Claude Desktop", "Library/Application Support/Claude/preview-last-frames", "cache", "delete", "Preview frame cache."),
    ("Claude Desktop", "Library/Application Support/Claude/declarative_performance_observer.db", "cache", "delete", "Perf observer db."),
    ("Claude Desktop", "Library/Application Support/Claude/declarative_performance_observer.db-journal", "cache", "delete", "Perf observer db journal."),
    ("Claude Desktop", "Library/Application Support/Claude/dxt-install-*", "cache", "delete", "Leftover temp extension install dirs."),
    ("Claude Desktop", "Library/Caches/com.anthropic.claudefordesktop", "cache", "delete", "macOS cache for Claude Desktop."),
    ("Claude Desktop", "Library/Caches/com.anthropic.claudefordesktop.ShipIt", "cache", "delete", "Updater cache."),
    ("Claude Desktop", "Library/Caches/claude-cli-nodejs", "cache", "delete", "Claude CLI node cache."),
    ("Claude Desktop", "Library/Application Support/Claude/Cookies", "auth", "keep", "Login session — kept so you stay signed in."),
    ("Claude Desktop", "Library/Application Support/Claude/claude_desktop_config.json", "config", "keep", "MCP/desktop config — kept."),
    ("Claude Desktop", "Library/Application Support/Claude/config.json", "config", "keep", "App config — kept."),
    ("Claude Desktop", "Library/Application Support/Claude/Claude Extensions", "config", "keep", "Installed extensions — kept."),
    ("Claude Desktop", "Library/Application Support/Claude/Claude Extensions Settings", "config", "keep", "Extension settings — kept."),
    ("Claude Desktop", "Library/Application Support/Claude/Preferences", "config", "keep", "App preferences — kept."),
    ("Claude Desktop", "Library/Application Support/Claude/Local State", "config", "keep", "Chromium browser state — kept."),

    # ── Codex ──
    ("Codex", ".codex/sessions", "history", "delete", "Session transcripts."),
    ("Codex", ".codex/archived_sessions", "history", "delete", "Archived session transcripts (167 MB)."),
    ("Codex", ".codex/history.jsonl", "history", "delete", "Prompt history."),
    ("Codex", ".codex/session_index.jsonl", "history", "delete", "Session index."),
    ("Codex", ".codex/memories", "data", "delete", "Agent memory files."),
    ("Codex", ".codex/memories_extensions", "data", "delete", "Extension memory data."),
    ("Codex", ".codex/memories_1.sqlite", "data", "delete", "Memory database."),
    ("Codex", ".codex/memories_1.sqlite-wal", "data", "delete", "Memory database WAL."),
    ("Codex", ".codex/memories_1.sqlite-shm", "data", "delete", "Memory database SHM."),
    ("Codex", ".codex/goals_1.sqlite", "data", "delete", "Goals database."),
    ("Codex", ".codex/goals_1.sqlite-wal", "data", "delete", "Goals database WAL."),
    ("Codex", ".codex/goals_1.sqlite-shm", "data", "delete", "Goals database SHM."),
    ("Codex", ".codex/logs_2.sqlite", "data", "delete", "Logs database (97 MB)."),
    ("Codex", ".codex/logs_2.sqlite-wal", "data", "delete", "Logs database WAL."),
    ("Codex", ".codex/logs_2.sqlite-shm", "data", "delete", "Logs database SHM."),
    ("Codex", ".codex/state_5.sqlite", "data", "delete", "App state database."),
    ("Codex", ".codex/state_5.sqlite-wal", "data", "delete", "App state WAL."),
    ("Codex", ".codex/state_5.sqlite-shm", "data", "delete", "App state SHM."),
    ("Codex", ".codex/computer-use", "data", "delete", "Computer-use screenshots/data (63 MB)."),
    ("Codex", ".codex/attachments", "data", "delete", "Session attachments."),
    ("Codex", ".codex/pets", "data", "delete", "Codex pets data."),
    ("Codex", ".codex/visualizations", "cache", "delete", "Generated visualizations."),
    ("Codex", ".codex/browser", "cache", "delete", "Browser automation profile."),
    ("Codex", ".codex/cache", "cache", "delete", "Misc cache."),
    ("Codex", ".codex/tmp", "cache", "delete", "Temp files."),
    ("Codex", ".codex/log", "cache", "delete", "Log files."),
    ("Codex", ".codex/shell_snapshots", "cache", "delete", "Shell snapshots."),
    ("Codex", ".codex/sqlite", "cache", "delete", "Sqlite staging dir."),
    ("Codex", ".codex/ipc", "cache", "delete", "Runtime IPC sockets."),
    ("Codex", ".codex/process_manager", "cache", "delete", "Runtime process state."),
    ("Codex", ".codex/mcp-oauth-locks", "cache", "delete", "OAuth lock files."),
    ("Codex", ".codex/worktrees", "cache", "delete", "Managed git worktrees."),
    ("Codex", ".codex/vendor_imports", "cache", "delete", "Vendored imports cache."),
    ("Codex", ".codex/models_cache.json", "cache", "delete", "Model list cache; refetched."),
    ("Codex", ".codex/installation_id", "data", "delete", "Install identifier (tracking)."),
    ("Codex", ".codex/version.json", "cache", "delete", "Version stamp; regenerated."),
    ("Codex", "Library/Caches/Codex", "cache", "delete", "macOS cache."),
    ("Codex", "Library/Caches/com.openai.codex", "cache", "delete", "macOS cache."),
    ("Codex", "Library/Caches/CodexBar", "cache", "delete", "CodexBar menu app cache."),
    ("Codex", "Library/Caches/com.steipete.codexbar", "cache", "delete", "CodexBar menu app cache."),
    ("Codex", ".codex/chrome-native-hosts.json", "config", "keep", "Chrome native-messaging manifests — deleting breaks browser extension integration."),
    ("Codex", ".codex/chrome-native-hosts-v2.json", "config", "keep", "Chrome native-messaging manifests — deleting breaks browser extension integration."),
    ("Codex", ".codex/config.toml", "config", "keep", "Your config — kept."),
    ("Codex", ".codex/AGENTS.md", "config", "keep", "Your agent instructions — kept."),
    ("Codex", ".codex/auth.json", "auth", "keep", "Login credentials — kept."),
    ("Codex", ".codex/rules", "config", "keep", "Custom rules — kept."),
    ("Codex", ".codex/skills", "config", "keep", "Installed skills — kept."),
    ("Codex", ".codex/plugins", "config", "keep", "Installed plugins (294 MB) — kept."),
    ("Codex", ".codex/automations", "config", "keep", "Your automations — kept."),
    ("Codex", ".codexbar", "config", "keep", "CodexBar config — kept."),

    # ── opencode ──
    ("opencode", ".local/share/opencode/opencode.db", "history", "delete", "All session history."),
    ("opencode", ".local/share/opencode/opencode.db-shm", "history", "delete", "Session db SHM."),
    ("opencode", ".local/share/opencode/opencode.db-wal", "history", "delete", "Session db WAL."),
    ("opencode", ".local/share/opencode/storage", "data", "delete", "Session/message storage."),
    ("opencode", ".local/share/opencode/snapshot", "data", "delete", "File snapshots from sessions."),
    ("opencode", ".local/share/opencode/log", "cache", "delete", "Logs."),
    ("opencode", ".local/share/opencode/tool-output", "cache", "delete", "Cached tool outputs."),
    ("opencode", ".local/share/opencode/repos", "data", "keep", "Repo clones — may contain unpushed work. Review manually."),
    ("opencode", ".local/share/opencode/auth.json", "auth", "keep", "Login credentials — kept."),
    ("opencode", ".config/opencode", "config", "keep", "Your config — kept."),

    # ── pi ──
    ("pi", ".pi/agent", "history", "delete", "Pi agent sessions/data (per your choice — past research session logs)."),
    ("pi", ".pi/browser-profile", "cache", "delete", "Embedded browser profile (320 MB); rebuilt on demand."),
    ("pi", ".pi/browser-profile.backend.json", "cache", "delete", "Browser profile state."),
    ("pi", ".pi/browser-profile.pages.json", "cache", "delete", "Browser profile state."),
    ("pi", ".pi/browser-profile.sites.json", "cache", "delete", "Browser profile state."),
    ("pi", ".pi/browser-profile.meta.json", "cache", "delete", "Browser profile state."),
    ("pi", ".pi/browser-profile.lock", "cache", "delete", "Browser profile lock."),
    ("pi", ".dot", "config", "keep", "Your dotfiles incl. pi config — never touched."),

    # ── Gemini CLI ──
    ("Gemini CLI", ".gemini/tmp", "cache", "delete", "Session temp dirs, downloaded binaries, chat temp data."),
    ("Gemini CLI", ".gemini/history", "history", "delete", "Prompt history."),
    ("Gemini CLI", ".gemini/installation_id", "data", "delete", "Install identifier (tracking)."),
    ("Gemini CLI", ".gemini/settings.json", "config", "keep", "Your settings — kept."),
    ("Gemini CLI", ".gemini/oauth_creds.json", "auth", "keep", "Login credentials — kept."),
    ("Gemini CLI", ".gemini/trustedFolders.json", "config", "keep", "Trust list — kept."),
    ("Gemini CLI", ".gemini/google_accounts.json", "auth", "keep", "Account info — kept."),

    # ── Ollama (models are weights, not harness data — kept by default) ──
    ("Ollama", ".ollama/history", "history", "delete", "Prompt history."),
    ("Ollama", ".ollama", "data", "keep", "25 GB of model weights — NOT deleted by default; deleting forces a full re-download. Remove manually if you no longer use ollama."),
    ("Ollama", "Library/Caches/com.electron.ollama.ShipIt", "cache", "delete", "Updater cache."),

    # ── ChatGPT / OpenAI desktop caches ──
    ("ChatGPT Desktop", "Library/Caches/com.openai.chat", "cache", "delete", "ChatGPT app cache."),
    ("ChatGPT Desktop", "Library/Caches/ChatGPTHelper", "cache", "delete", "ChatGPT helper cache."),
    ("ChatGPT Desktop", "Library/Caches/com.openai.codex", "cache", "delete", "Codex macOS cache."),
    ("ChatGPT Desktop", "Library/Caches/com.openai.sky.CUAService", "cache", "delete", "OpenAI computer-use service cache."),
    ("ChatGPT Desktop", "Library/Caches/com.openai.sky.CUAService.cli", "cache", "delete", "OpenAI computer-use CLI cache."),
    ("ChatGPT Desktop", "Library/Logs/Claude", "cache", "delete", "Claude Desktop log files (49 MB)."),
    ("ChatGPT Desktop", "Library/Logs/com.openai.codex", "cache", "delete", "Codex log files."),

    # ── macOS per-app network/web data (all harnesses) ──
    ("Claude Desktop", "Library/WebKit/com.openai.chat", "cache", "delete", "ChatGPT app webkit storage (18 MB)."),
    ("Claude Desktop", "Library/HTTPStorages/com.anthropic.claudefordesktop", "cache", "delete", "Network cache; rebuilt automatically. Login lives in Cookies (kept)."),
    ("Claude Desktop", "Library/HTTPStorages/com.anthropic.claudefordesktop.binarycookies", "data", "delete", "Tracking cookies."),
    ("ChatGPT Desktop", "Library/HTTPStorages/com.openai.chat", "cache", "delete", "Network cache; rebuilt automatically."),
    ("ChatGPT Desktop", "Library/HTTPStorages/com.openai.chat.binarycookies", "data", "delete", "Tracking cookies."),
    ("Codex", "Library/HTTPStorages/com.openai.codex", "cache", "delete", "Network cache; rebuilt automatically."),
    ("Codex", "Library/HTTPStorages/com.openai.codex.binarycookies", "data", "delete", "Tracking cookies."),
    ("ChatGPT Desktop", "Library/HTTPStorages/com.openai.sky.CUAService", "cache", "delete", "Computer-use service network cache."),
    ("ChatGPT Desktop", "Library/HTTPStorages/com.openai.sky.CUAService.binarycookies", "data", "delete", "Tracking cookies."),
    ("ChatGPT Desktop", "Library/HTTPStorages/com.openai.sky.CUAService.cli", "cache", "delete", "Computer-use CLI network cache."),
    ("ChatGPT Desktop", "Library/HTTPStorages/com.openai.sky.CUAService.cli.binarycookies", "data", "delete", "Tracking cookies."),
    ("Hugging Face", ".cache/huggingface", "cache", "delete", "Model/dataset cache (1 MB here); re-downloaded on demand."),

    # ── Codex desktop app (Chromium-based; separate from ~/.codex) ──
    ("Codex", "Library/Application Support/Codex", "cache", "delete", "541 MB Chromium browser profile for the Codex app; rebuilt on next launch, re-auth if prompted."),

    # ── Browser-automation caches ──
    ("Misc AI", ".cache/puppeteer", "cache", "delete", "550 MB downloaded Chromium for MCP/browser automation; re-downloaded on demand."),

    # ── Linux equivalents (skipped silently on macOS, where they don't exist) ──
    ("Claude Code", ".cache/claude-cli-nodejs", "cache", "delete", "Claude Code cache on Linux (XDG path)."),
    ("Codex", ".cache/codex-runtimes", "cache", "delete", "Codex runtime downloads (1.6 GB); re-fetched when needed."),
    ("opencode", ".local/state/opencode", "data", "delete", "opencode runtime state."),
    ("opencode", ".cache/opencode", "cache", "delete", "opencode cache (XDG path)."),
]

CATALOG[:] = [(h, str(Path(p).expanduser()), c, a, r) for h, p, c, a, r in CATALOG]

RUNNING_PROCESSES = ["claude", "codex", "opencode", "pi", "Claude"]


def human_size(n):
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024 or unit == "TB":
            return f"{n:,.0f} {unit}" if unit == "B" else f"{n:,.1f} {unit}"
        n /= 1024


def path_size(p):
    if p.is_file():
        return p.stat().st_size, 1
    total, count = 0, 0
    try:
        for root, _dirs, files in os.walk(p, onerror=lambda e: None):
            for f in files:
                try:
                    total += (Path(root) / f).stat().st_size
                    count += 1
                except OSError:
                    pass
    except OSError:
        pass
    return total, count


def expand(entry_path):
    """Expand glob patterns / '~' in a catalog path to existing paths."""
    if any(ch in entry_path for ch in "*?["):
        return [Path(x) for x in glob.glob(entry_path)]
    p = Path(entry_path)
    return [p] if p.exists() else []


def running_processes():
    alive = []
    for name in RUNNING_PROCESSES:
        r = subprocess.run(["pgrep", "-x", name], capture_output=True)
        if r.returncode == 0:
            alive.append(name)
    return alive


def scan():
    """Yield dicts: one per existing concrete path, with size/file count."""
    rows = []
    seen = set()
    for harness, path, cat, action, reason in CATALOG:
        matches = expand(path) if action == "delete" else ([p for p in [Path(path)] if p.exists()])
        if action == "delete" and not matches:
            matches = []  # missing; skip silently, show nothing
        for m in matches:
            if m in seen:
                continue
            seen.add(m)
            size, files = path_size(m)
            rows.append(dict(harness=harness, path=m, cat=cat, action=action,
                             reason=reason, size=size, files=files))
    return rows


def fmt_path(p):
    s = str(p)
    return s.replace(str(HOME), "~", 1)


# ── HTML report ──────────────────────────────────────────────────────────────

CAT_COLORS = {"cache": "#58a6ff", "history": "#f85149", "data": "#d29922",
              "auth": "#3fb950", "config": "#3fb950"}


def render(rows, delete_mode):
    reclaim = sum(r["size"] for r in rows if r["action"] == "delete")
    keep = sum(r["size"] for r in rows if r["action"] == "keep")
    by_cat = {}
    for r in rows:
        if r["action"] == "delete":
            by_cat[r["cat"]] = by_cat.get(r["cat"], 0) + r["size"]

    harnesses = {}
    for r in rows:
        harnesses.setdefault(r["harness"], []).append(r)
    for h in harnesses:
        harnesses[h].sort(key=lambda r: (r["action"] != "delete", -r["size"]))
    order = sorted(harnesses, key=lambda h: -sum(r["size"] for r in harnesses[h] if r["action"] == "delete"))

    mode_badge = ('<span style="color:#f85149;border:1px solid #f85149">'
                  f'{"DELETING NOW" if delete_mode else "REPORT ONLY — nothing deleted yet"}</span>')

    chips = "".join(
        f'<div class="chip"><span class="dot" style="background:{CAT_COLORS[c]}"></span>'
        f'{c}: <b>{human_size(s)}</b></div>'
        for c, s in sorted(by_cat.items(), key=lambda kv: -kv[1]))

    sections = []
    for h in order:
        hrs = harnesses[h]
        h_reclaim = sum(r["size"] for r in hrs if r["action"] == "delete")
        rows_html = "".join(
            f'<tr class="{"del" if r["action"] == "delete" else "keep-row"}">'
            f'<td class="mono">{fmt_path(r["path"])}</td>'
            f'<td><span class="badge" style="border-color:{CAT_COLORS[r["cat"]]};color:{CAT_COLORS[r["cat"]]}">{r["cat"]}</span></td>'
            f'<td class="num">{human_size(r["size"])}</td>'
            f'<td class="num">{r["files"]:,}</td>'
            f'<td class="{"act-del" if r["action"] == "delete" else "act-keep"}">'
            f'{"DELETE" if r["action"] == "delete" else "KEEP"}</td>'
            f'<td class="reason">{r["reason"]}</td></tr>'
            for r in hrs)
        sections.append(f"""
        <div class="card">
          <h2>{h} <span class="harness-total">{human_size(h_reclaim)} reclaimable</span></h2>
          <table>
            <tr><th>Path</th><th>Category</th><th>Size</th><th>Files</th><th>Action</th><th>Why</th></tr>
            {rows_html}
          </table>
        </div>""")

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<title>AI Harness Data Scrub — {now}</title>
<style>
  :root {{ color-scheme: dark; }}
  * {{ box-sizing: border-box; margin: 0; }}
  body {{ background: #0d1117; color: #c9d1d9; font: 14px/1.5 -apple-system, 'Segoe UI', sans-serif; padding: 32px; }}
  .wrap {{ max-width: 1200px; margin: 0 auto; }}
  h1 {{ color: #e6edf3; font-size: 26px; margin-bottom: 4px; }}
  .sub {{ color: #8b949e; margin-bottom: 20px; }}
  .mode {{ font-size: 12px; font-weight: 600; padding: 2px 10px; border-radius: 12px; }}
  .summary {{ display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 20px; }}
  .stat {{ background: #161b22; border: 1px solid #30363d; border-radius: 10px; padding: 16px 22px; min-width: 180px; }}
  .stat .n {{ font-size: 24px; font-weight: 700; }}
  .stat .l {{ color: #8b949e; font-size: 12px; text-transform: uppercase; letter-spacing: .05em; }}
  .red {{ color: #f85149; }} .green {{ color: #3fb950; }}
  .chips {{ display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 24px; }}
  .chip {{ background: #161b22; border: 1px solid #30363d; border-radius: 20px; padding: 5px 14px; font-size: 13px;
          display: flex; align-items: center; gap: 8px; }}
  .dot {{ width: 9px; height: 9px; border-radius: 50%; display: inline-block; }}
  .card {{ background: #161b22; border: 1px solid #30363d; border-radius: 10px; margin-bottom: 24px; overflow: hidden; }}
  .card h2 {{ color: #e6edf3; font-size: 16px; padding: 14px 18px; border-bottom: 1px solid #30363d; }}
  .harness-total {{ float: right; color: #f85149; font-size: 13px; font-weight: 600; }}
  table {{ width: 100%; border-collapse: collapse; font-size: 13px; }}
  th {{ text-align: left; color: #8b949e; font-weight: 600; padding: 8px 18px; border-bottom: 1px solid #30363d;
       text-transform: uppercase; font-size: 11px; letter-spacing: .05em; }}
  td {{ padding: 8px 18px; border-bottom: 1px solid #21262d; vertical-align: top; }}
  tr:last-child td {{ border-bottom: none; }}
  tr:hover td {{ background: #1c2128; }}
  tr.del td {{ background: rgba(248, 81, 73, .04); }}
  tr.keep-row td {{ opacity: .55; }}
  .mono {{ font-family: 'SF Mono', Menlo, monospace; font-size: 12px; color: #e6edf3; word-break: break-all; }}
  .badge {{ font-size: 11px; font-weight: 600; border: 1px solid; border-radius: 10px; padding: 1px 9px; white-space: nowrap; }}
  .num {{ text-align: right; white-space: nowrap; font-variant-numeric: tabular-nums; }}
  .act-del {{ color: #f85149; font-weight: 700; white-space: nowrap; }}
  .act-keep {{ color: #3fb950; font-weight: 700; white-space: nowrap; }}
  .reason {{ color: #8b949e; max-width: 420px; }}
  .foot {{ color: #484f58; font-size: 12px; margin-top: 8px; text-align: center; }}
</style></head><body><div class="wrap">
  <h1>🧹 AI Harness Data Scrub</h1>
  <p class="sub">Generated {now} &nbsp;·&nbsp; <span class="mode">{mode_badge}</span> &nbsp;·&nbsp; configs and logins are always kept</p>
  <div class="summary">
    <div class="stat"><div class="n red">{human_size(reclaim)}</div><div class="l">Will be deleted</div></div>
    <div class="stat"><div class="n green">{human_size(keep)}</div><div class="l">Kept (configs, auth)</div></div>
    <div class="stat"><div class="n">{sum(r["files"] for r in rows if r["action"] == "delete"):,}</div><div class="l">Files affected</div></div>
  </div>
  <div class="chips">{chips}</div>
  {''.join(sections)}
  <p class="foot">Report only — run with <code>--delete</code> to remove the DELETE rows. Keep rows are never touched.</p>
</div></body></html>"""


def main():
    ap = argparse.ArgumentParser(description="Scrub AI agent harness data (keeps configs). Dry-run by default.")
    ap.add_argument("--delete", action="store_true", help="Actually delete (default: report only)")
    ap.add_argument("--no-open", action="store_true", help="Don't open the report in a browser")
    ap.add_argument("--check", action="store_true", help="Run self-test and exit")
    args = ap.parse_args()

    if args.check:
        assert human_size(0).endswith("0 B")
        assert human_size(1536 * 1024 * 1024).endswith("1.5 GB")
        assert path_size(Path("/nonexistent-xyz")) == (0, 0)
        assert expand("/nonexistent-xyz/*.tmp") == []
        rows = scan()
        assert all(r["size"] >= 0 and r["files"] >= 0 for r in rows)
        # dedup: no concrete path scanned twice
        paths = [r["path"] for r in rows]
        assert len(paths) == len(set(paths)), "duplicate catalog paths"
        print(f"check ok — {len(rows)} catalog paths found on disk")
        return

    rows = scan()
    reclaim = sum(r["size"] for r in rows if r["action"] == "delete")
    if not rows:
        print("Nothing found — nothing to scrub.")
        return

    if args.delete:
        alive = running_processes()
        if alive:
            print(f"ABORT: these are running: {', '.join(alive)}. Quit them first (sqlite/WAL corruption risk).")
            sys.exit(1)

    TMP.mkdir(parents=True, exist_ok=True)
    report = TMP / f"ai-scrub-report-{datetime.now():%Y%m%d-%H%M%S}.html"
    report.write_text(render(rows, args.delete))

    print(f"Report: {report}")
    if not args.no_open:
        webbrowser.open(report.as_uri())

    if not args.delete:
        print(f"DRY RUN — nothing deleted. {human_size(reclaim)} reclaimable across "
              f"{sum(1 for r in rows if r['action'] == 'delete')} paths. Re-run with --delete to scrub.")
        return

    print("Deleting…")
    freed = errors = 0
    for r in sorted((r for r in rows if r["action"] == "delete"), key=lambda r: -r["size"]):
        try:
            if r["path"].is_dir() and not r["path"].is_symlink():
                shutil.rmtree(r["path"])
            elif r["path"].exists():
                r["path"].unlink()
                # sqlite sidecars live next to deleted db files
                for suffix in ("-wal", "-shm"):
                    Path(str(r["path"]) + suffix).unlink(missing_ok=True)
            freed += r["size"]
            print(f"  ✓ {fmt_path(r['path'])}  ({human_size(r['size'])})")
        except FileNotFoundError:
            freed += r["size"]  # vanished between scan and delete — count as gone
        except OSError as e:
            errors += 1
            print(f"  ✗ {fmt_path(r['path'])}: {e}")
    print(f"\nDone. Freed {human_size(freed)}; {errors} errors. Report kept at {report}")


if __name__ == "__main__":
    main()
