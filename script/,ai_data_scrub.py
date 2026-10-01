#!/usr/bin/env python3
"""Scrub AI agent harness data (sessions, caches, telemetry, memories) — keep configs.

Default: dry-run. Builds a dark HTML report in ~/tmp and opens it in the browser.
Run with --delete to actually delete what the report lists.

Usage:
    python3 ai_data_scrub.py            # report only, deletes nothing
    python3 ai_data_scrub.py --delete   # delete after report
    python3 ai_data_scrub.py --be-gone  # interactive: pick harnesses, then per
                                        #   harness tier: data / all incl configs
                                        #   / uninstall app + everything
    python3 ai_data_scrub.py --no-open  # report without opening browser
    python3 ai_data_scrub.py --check    # tiny self-test

--be-gone never touches ~/dot or ~/.dot (your dotfiles repo), in any tier.

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
import zipfile
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

    # ── Hermes ──
    ("Hermes", ".hermes/sessions", "history", "delete", "Session transcripts."),
    ("Hermes", ".hermes/memories", "data", "delete", "Agent memory files."),
    ("Hermes", ".hermes/logs", "cache", "delete", "Log files."),
    ("Hermes", ".hermes/cache", "cache", "delete", "Misc cache (246 MB); rebuilt on demand."),
    ("Hermes", ".hermes/audio_cache", "cache", "delete", "Generated audio cache."),
    ("Hermes", ".hermes/image_cache", "cache", "delete", "Generated image cache."),
    ("Hermes", ".hermes/bootstrap-cache", "cache", "delete", "Bootstrap downloads."),
    ("Hermes", ".hermes/source-checks", "cache", "delete", "Source-check scratch data."),
    ("Hermes", ".hermes/runtime", "cache", "delete", "Runtime scratch space."),
    ("Hermes", ".hermes/terminal-sessions", "cache", "delete", "Terminal session state."),
    ("Hermes", ".hermes/desktop", "cache", "delete", "Desktop integration cache."),
    ("Hermes", ".hermes/sandboxes", "data", "delete", "Agent sandboxes."),
    ("Hermes", ".hermes/bot_relay", "data", "delete", "Bot relay queue."),
    ("Hermes", ".hermes/backups", "data", "delete", "Auto-backups."),
    ("Hermes", ".hermes/state.db", "data", "delete", "Runtime state database."),
    ("Hermes", ".hermes/state.db-shm", "data", "delete", "State database SHM."),
    ("Hermes", ".hermes/state.db-wal", "data", "delete", "State database WAL."),
    ("Hermes", ".hermes/projects.db", "data", "delete", "Projects database."),
    ("Hermes", ".hermes/shared-state.db", "data", "delete", "Shared state database."),
    ("Hermes", ".hermes/spawn-ledger.json", "data", "delete", "Spawn ledger (tracking)."),
    ("Hermes", ".hermes/install_id", "data", "delete", "Install identifier (tracking)."),
    ("Hermes", ".hermes/models_dev_cache.json", "cache", "delete", "Model list cache; refetched."),
    ("Hermes", ".hermes/models_dev_cache.etag", "cache", "delete", "Model list cache etag."),
    ("Hermes", ".hermes/provider_models_cache.json", "cache", "delete", "Provider model cache; refetched."),
    ("Hermes", ".hermes/context_length_cache.yaml", "cache", "delete", "Context length cache; refetched."),
    ("Hermes", ".local/bin/hermes", "data", "delete", "Launcher script."),
    ("Hermes", ".local/bin/hermes-agent", "data", "delete", "Launcher script."),
    ("Hermes", ".local/bin/hermes-acp", "data", "delete", "Launcher script."),
    ("Hermes", ".local/bin/herdr", "data", "delete", "Helper binary."),
    ("Hermes", ".hermes/hermes-agent", "data", "keep", "Full agent install (2.3 GB) — review manually."),
    ("Hermes", ".hermes/installs", "data", "keep", "Versioned installs (345 MB) — review manually."),
    ("Hermes", ".hermes/tools", "data", "keep", "Bundled tools (970 MB) — review manually."),
    ("Hermes", ".hermes/hermes-setup", "data", "keep", "Setup bundle — review manually."),
    ("Hermes", ".hermes/config.yaml", "config", "keep", "Your config — kept."),
    ("Hermes", ".hermes/auth.json", "auth", "keep", "Login credentials — kept."),
    ("Hermes", ".hermes/skills", "config", "keep", "Installed skills — kept."),
    ("Hermes", ".hermes/plugins", "config", "keep", "Installed plugins — kept."),
    ("Hermes", ".hermes/hooks", "config", "keep", "Your hooks — kept."),
    ("Hermes", ".hermes/desktop-plugins", "config", "keep", "Desktop plugins — kept."),
    ("Hermes", ".hermes/pairing", "config", "keep", "Device pairing — kept."),
    ("Hermes", ".hermes/shared", "config", "keep", "Shared config — kept."),
    ("Hermes", ".hermes/SOUL.md", "config", "keep", "Agent persona — kept."),

    # ── OpenClaw / ClawHub ──
    ("OpenClaw", ".openclaw/browser", "cache", "delete", "Automation browser profile (107 MB); rebuilt on demand."),
    ("OpenClaw", ".openclaw/logs", "cache", "delete", "Log files."),
    ("OpenClaw", ".openclaw/media", "cache", "delete", "Media cache."),
    ("OpenClaw", ".openclaw/update-check.json", "cache", "delete", "Update check stamp."),
    ("OpenClaw", ".openclaw/memory", "data", "delete", "Agent memory."),
    ("OpenClaw", ".openclaw/cron", "data", "delete", "Scheduled jobs."),
    ("OpenClaw", ".openclaw/devices", "data", "delete", "Paired devices."),
    ("OpenClaw", "Library/LaunchAgents/ai.openclaw.gateway.plist", "data", "delete", "Gateway launch agent."),
    ("OpenClaw", ".openclaw/agents", "data", "keep", "Agent definitions — review manually."),
    ("OpenClaw", ".openclaw/workspace", "data", "keep", "Workspace files (40 MB) — review manually."),
    ("OpenClaw", ".openclaw/canvas", "data", "keep", "Canvas data — review manually."),
    ("OpenClaw", ".openclaw/identity", "auth", "keep", "Identity keys — kept."),
    ("OpenClaw", ".openclaw/openclaw.json", "config", "keep", "Your config — kept."),

    # ── Grok CLI ──
    ("Grok CLI", ".grok/settings.json", "config", "keep", "Your settings — kept."),
    ("Grok CLI", ".grok/user-settings.json", "auth", "keep", "User settings/token — kept."),
    ("Grok CLI", ".grok/hooks", "config", "keep", "Your hooks — kept."),

    # ── CodexBar (menu bar app) ──
    ("CodexBar", "Library/Application Support/CodexBar", "cache", "delete", "App support."),
    ("CodexBar", "Library/Application Support/com.steipete.codexbar", "cache", "delete", "App support."),
    ("CodexBar", "Library/Group Containers/group.com.steipete.codexbar", "data", "delete", "Shared container."),
    ("CodexBar", "Library/WebKit/com.steipete.codexbar", "cache", "delete", "WebKit storage."),
    ("CodexBar", "Library/Containers/com.steipete.codexbar", "cache", "delete", "Sandbox container."),
    ("CodexBar", "Library/Containers/com.steipete.codexbar.widget", "cache", "delete", "Widget container (needs sudo)."),
    ("CodexBar", "Library/HTTPStorages/com.steipete.codexbar", "cache", "delete", "Network cache."),
    ("CodexBar", "Library/HTTPStorages/com.steipete.codexbar.binarycookies", "data", "delete", "Tracking cookies."),
    ("CodexBar", "Library/Preferences/com.steipete.codexbar.plist", "config", "keep", "Preferences — kept."),

    # ── AI-adjacent editors ──
    ("VS Code", ".vscode", "data", "delete", "Extensions, workspaces, argv (1.0 GB)."),
    ("VS Code", "Library/Application Support/Code", "data", "delete", "User data: settings, snippets, history (772 MB)."),
    ("VS Code", "Library/Caches/com.microsoft.VSCode", "cache", "delete", "macOS cache."),
    ("VS Code", "Library/Caches/com.microsoft.VSCode.ShipIt", "cache", "delete", "Updater cache."),
    ("VS Code", "Library/HTTPStorages/com.microsoft.VSCode", "cache", "delete", "Network cache."),
    ("VS Code", "Library/Preferences/com.microsoft.VSCode.plist", "config", "keep", "Preferences — kept."),
    ("Cursor", ".cursor", "data", "delete", "Extensions, projects, AI tracking, plugins."),
    ("Cursor", "Library/Application Support/Cursor", "data", "delete", "User data and caches (35 MB)."),
    ("Cursor", "Library/Preferences/com.todesktop.230313mzl4w4u92.plist", "config", "keep", "Preferences — kept on macOS."),

    # ── Linux equivalents (skipped silently on macOS, where they don't exist) ──
    ("Claude Code", ".cache/claude-cli-nodejs", "cache", "delete", "Claude Code cache on Linux (XDG path)."),
    ("Codex", ".cache/codex-runtimes", "cache", "delete", "Codex runtime downloads (1.6 GB); re-fetched when needed."),
    ("opencode", ".local/state/opencode", "data", "delete", "opencode runtime state."),
    ("opencode", ".cache/opencode", "cache", "delete", "opencode cache (XDG path)."),
]

# Anchor relative catalog paths at $HOME — expanduser only handles '~', so
# without this the script's results depend on the cwd it was launched from.
CATALOG[:] = [(h, str(Path(p).expanduser() if p.startswith(("~", "/")) else HOME / p),
               c, a, r) for h, p, c, a, r in CATALOG]

RUNNING_PROCESSES = ["claude", "codex", "opencode", "pi", "Claude", "ChatGPT", "Ollama", "ollama"]


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


def delete_paths(items):
    """Delete [(Path, size)] in the given order. Returns (freed, errors)."""
    freed = errors = 0
    for path, size in items:
        try:
            if path.is_dir() and not path.is_symlink():
                shutil.rmtree(path)
            elif path.exists():
                path.unlink()
                # sqlite sidecars live next to deleted db files
                for suffix in ("-wal", "-shm"):
                    Path(str(path) + suffix).unlink(missing_ok=True)
            freed += size
            print(f"  ✓ {fmt_path(path)}  ({human_size(size)})")
        except FileNotFoundError:
            freed += size  # vanished between scan and delete — count as gone
        except OSError as e:
            errors += 1
            print(f"  ✗ {fmt_path(path)}: {e}")
    return freed, errors


# ── --be-gone: interactive full uninstall ────────────────────────────────────
# Tiers: d = catalog "delete" rows only (same paths as --delete, per harness)
#        a = every catalog row for that harness (configs, auth, skills included)
#        u = tier a + the app itself: bundle, plists, keychain, launch agents, CLI
# ~/dot and ~/.dot are NEVER touched, in any tier.

APPS = {
    "Claude Code": dict(
        roots=[".claude"], bundles=[], bundle_ids=[],
        cli=[("claude", "@anthropic-ai/claude-code")],
        keychain=["Claude Code", "Claude Code-credentials"], launch_tokens=["claude"]),
    "Claude Desktop": dict(
        roots=["Library/Application Support/Claude"],
        bundles=["/Applications/Claude.app"], bundle_ids=["com.anthropic.claudefordesktop"],
        cli=[], keychain=["Claude", "Claude Safe Storage"], launch_tokens=["claude"]),
    "Codex": dict(
        roots=[".codex"], bundles=["/Applications/Codex.app"], bundle_ids=["com.openai.codex"],
        cli=[("codex", "@openai/codex")],
        keychain=["Codex", "OpenAI"], launch_tokens=["codex", "openai"]),
    "opencode": dict(
        roots=[".opencode", ".local/share/opencode", ".config/opencode",
               ".local/state/opencode", ".cache/opencode"],
        bundles=[], bundle_ids=[], cli=[("opencode", "opencode-ai")],
        keychain=["opencode"], launch_tokens=["opencode"]),
    "pi": dict(
        roots=[".pi"], bundles=[], bundle_ids=[],
        cli=[("pi", "@earendil-works/pi-coding-agent")],
        keychain=["pi"], launch_tokens=["earendil", "pi-coding-agent"]),
    "Gemini CLI": dict(
        roots=[".gemini"], bundles=[], bundle_ids=[],
        cli=[("gemini", "@google/gemini-cli")],
        keychain=["Gemini"], launch_tokens=["gemini"]),
    "Ollama": dict(
        roots=[".ollama"], bundles=["/Applications/Ollama.app"], bundle_ids=["com.ollama"],
        cli=[("ollama", "ollama")],
        keychain=["Ollama"], launch_tokens=["ollama"]),
    "ChatGPT Desktop": dict(
        roots=["Library/Application Support/ChatGPT"],
        bundles=["/Applications/ChatGPT.app"], bundle_ids=["com.openai.chat"],
        cli=[], keychain=["ChatGPT", "OpenAI"], launch_tokens=["chatgpt", "openai.chat"]),
    "Hermes": dict(
        roots=[".hermes"], bundles=[], bundle_ids=[],
        cli=[], keychain=["Hermes"], launch_tokens=["hermes"]),
    "OpenClaw": dict(
        roots=[".openclaw"], bundles=[], bundle_ids=[],
        cli=[("openclaw", "openclaw")], keychain=["OpenClaw"], launch_tokens=["openclaw", "clawhub"]),
    "Grok CLI": dict(
        roots=[".grok"], bundles=[], bundle_ids=[],
        cli=[("grok", "@vibe-kit/grok-cli")], keychain=[], launch_tokens=["grok-cli", "vibe-kit"]),
    "CodexBar": dict(
        roots=[], bundles=["/Applications/CodexBar.app"],
        bundle_ids=["com.steipete.codexbar"], cli=[], keychain=["CodexBar"], launch_tokens=["codexbar"]),
    "VS Code": dict(
        roots=[".vscode"], bundles=["/Applications/Visual Studio Code.app"],
        bundle_ids=["com.microsoft.VSCode"], cli=[], keychain=[], launch_tokens=[]),
    "Cursor": dict(
        roots=[".cursor"], bundles=["/Applications/Cursor.app"],
        bundle_ids=["com.todesktop.230313mzl4w4u92"], cli=[], keychain=["Cursor"], launch_tokens=["cursor"]),
}

TIER_LABEL = {"d": "DATA ONLY", "a": "ALL INCL CONFIGS+AUTH",
              "u": "UNINSTALL — APP + EVERYTHING"}
NEVER = {HOME / "dot", HOME / ".dot"}  # dotfiles repo — survives every tier


def is_never(p):
    return p in NEVER or Path(os.path.realpath(p)) in NEVER


def bundle_paths(bid):
    """All Library locations a macOS bundle id leaves behind."""
    lib = HOME / "Library"
    cands = [f"Preferences/{bid}.plist", f"Caches/{bid}", f"WebKit/{bid}",
             f"Saved Application State/{bid}.savedState",
             f"Application Scripts/{bid}", f"Containers/{bid}"]
    cands += glob.glob(str(lib / "HTTPStorages" / f"{bid}*"))
    cands += glob.glob(str(lib / "Group Containers" / f"*{bid}*"))
    return [(lib / c, 0) for c in cands if (lib / c).exists()]


def uninstall_extras(h):
    """Extra (paths, specs) removed at tier u.
    specs: ('defaults', bid) | ('keychain', name) | ('cli', cli, pkg)."""
    spec = APPS.get(h, {})
    paths, specs = [], []
    for b in spec.get("bundles", []):
        if Path(b).exists():
            paths.append((Path(b), 0))
    for bid in spec.get("bundle_ids", []):
        paths += bundle_paths(bid)
        specs.append(("defaults", bid))
    for root in spec.get("roots", []):
        p = HOME / root
        if p.exists():
            paths.append((p, 0))
    for name in spec.get("keychain", []):
        specs.append(("keychain", name))
    for cli, pkg in spec.get("cli", []):
        specs.append(("cli", cli, pkg))
    la = HOME / "Library/LaunchAgents"
    if la.is_dir():
        for f in la.glob("*.plist"):
            try:
                txt = f.read_text(errors="ignore").lower()
            except OSError:
                continue
            if any(t in txt for t in spec.get("launch_tokens", [])):
                paths.append((f, 0))
    return paths, specs


def spec_desc(s):
    if s[0] == "defaults":
        return f"defaults delete {s[1]}"
    if s[0] == "keychain":
        return f"keychain items matching {s[1]!r} (best effort)"
    return f"uninstall cli: {s[1]} (pkg {s[2]})"


def run_specs(specs):
    for s in specs:
        if s[0] == "defaults":
            subprocess.run(["defaults", "delete", s[1]], capture_output=True)
        elif s[0] == "keychain":
            for opt in (("-s", s[1]), ("-a", s[1])):
                subprocess.run(["security", "delete-generic-password", *opt],
                               capture_output=True)
            print(f"  ⚿ {spec_desc(s)}")
        elif s[0] == "cli":
            print(f"  ⌘ {uninstall_cli(s[1], s[2])}")


def uninstall_cli(cli, pkg):
    p = shutil.which(cli)
    if not p:
        return f"{cli}: not on PATH (nothing to do)"
    real = str(Path(p).resolve())
    try:
        prefix = subprocess.run(["npm", "prefix", "-g"], capture_output=True,
                                text=True).stdout.strip()
    except OSError:
        prefix = ""
    if prefix and real.startswith(prefix + os.sep):
        subprocess.run(["npm", "uninstall", "-g", pkg], capture_output=True)
        return f"npm uninstall -g {pkg} ({p})"
    if "/Cellar/" in real or "/homebrew/" in real:
        subprocess.run(["brew", "uninstall", cli], capture_output=True)
        return f"brew uninstall {cli} ({p})"
    return f"unknown install method — remove manually: {p}"


def parse_sel(s, n):
    """'all', '1,3', '1-3' → sorted unique picks, or None if nothing valid."""
    s = s.strip().lower()
    out = set()
    if s == "all":
        out.update(range(1, n + 1))
    else:
        for part in s.split(","):
            part = part.strip()
            a, _, b = part.partition("-")
            if b.isdigit() and a.isdigit() and 1 <= int(a) <= int(b) <= n:
                out.update(range(int(a), int(b) + 1))
            elif a.isdigit() and 1 <= int(a) <= n:
                out.add(int(a))
    return sorted(out) or None


def ask(prompt):
    try:
        return input(prompt)
    except (EOFError, KeyboardInterrupt):
        sys.exit("\nAborted — nothing deleted.")


def ask_tier(h):
    can_u = h in APPS
    while True:
        hint = "[d]ata / [a]ll incl configs+auth" + (" / [u]ninstall app+everything" if can_u else "")
        a = ask(f"  {h} — {hint} [d]: ").strip().lower() or "d"
        if a in ("d", "a") or (a == "u" and can_u):
            return a
        print(f"  ? answer d, a{', u' if can_u else ''}")


def backup_zip(paths):
    out = TMP / f"ai-scrub-backup-{datetime.now():%Y%m%d-%H%M%S}.zip"
    n = 0
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for p in paths:
            if is_never(p):
                continue
            p = Path(p)
            if p.is_file():
                z.write(p, str(p.relative_to(HOME)))
                n += 1
            elif p.is_dir():
                for root, _dirs, files in os.walk(p):
                    for f in files:
                        fp = Path(root) / f
                        z.write(fp, str(fp.relative_to(HOME)))
                        n += 1
    return out, n


def build_plan(rows, picks):
    """Merge catalog rows + uninstall extras into a per-harness plan;
    drop nested/duplicate paths so nothing is deleted or counted twice."""
    plan = []
    for h, tier in picks.items():
        hrows = [r for r in rows if r["harness"] == h]
        if tier == "d":
            sel = [(r["path"], r["size"]) for r in hrows if r["action"] == "delete"]
            specs = []
        else:
            sel = [(r["path"], r["size"]) for r in hrows]
            specs = []
        extra_paths = []
        if tier == "u":
            extra_paths, specs = uninstall_extras(h)
            extra_paths = [(p, path_size(p)[0]) for p, _ in extra_paths]  # real sizes
            sel += extra_paths
        backup = [r["path"] for r in hrows
                  if tier != "d" and r["cat"] in ("config", "auth") and not is_never(r["path"])]
        merged = {}
        for p, s in sel:
            if not is_never(p):
                merged[p] = max(merged.get(p, 0), s)
        plan.append(dict(harness=h, tier=tier, paths=merged, specs=specs,
                         extra={p for p, _ in extra_paths}, backup=backup))
    # drop paths nested inside another planned path: no double counting, no
    # redundant rmtree of children the parent deletion already covers
    all_p = [p for e in plan for p in e["paths"]]
    nested = {p for p in all_p for q in all_p
              if q != p and str(p).startswith(str(q) + os.sep)}
    for e in plan:
        e["paths"] = {p: s for p, s in e["paths"].items() if p not in nested}
    return plan


def be_gone():
    if not sys.stdin.isatty():
        print("ABORT: --be-gone is interactive and needs a TTY.")
        sys.exit(1)
    rows = scan()
    installed = sorted({r["harness"] for r in rows})
    for name, spec in APPS.items():
        if name not in installed and (
                any(Path(b).exists() for b in spec["bundles"])
                or any(shutil.which(c) for c, _ in spec["cli"])):
            installed.append(name)
    installed.sort(key=lambda h: -sum(r["size"] for r in rows if r["harness"] == h))
    if not installed:
        print("No AI harness data found — nothing to remove.")
        return

    print("Installed AI harnesses:")
    for i, h in enumerate(installed, 1):
        total = sum(r["size"] for r in rows if r["harness"] == h)
        print(f"  {i}. {h:<16} {human_size(total):>9}")

    while True:
        nums = parse_sel(ask("\nSelect (e.g. 1,3 or all): "), len(installed))
        if nums:
            break
        print("  ? try e.g. 1,3 or all")
    picks = {installed[n - 1]: ask_tier(installed[n - 1]) for n in nums}

    plan = build_plan(rows, picks)
    print("\nPLAN:")
    total = 0
    for e in plan:
        t = sum(e["paths"].values())
        total += t
        print(f"  ✗ {e['harness']} — {TIER_LABEL[e['tier']]} — "
              f"{human_size(t)}, {len(e['paths'])} paths")
        for p, s in sorted(e["paths"].items(), key=lambda kv: -kv[1]):
            if p in e["extra"]:
                print(f"      {fmt_path(p)} ({human_size(s)})")
        for s in e["specs"]:
            print(f"      {spec_desc(s)}")
    print(f"\n  Total: {human_size(total)}")

    backup_paths = [p for e in plan for p in e["backup"]]
    if backup_paths and ask("\nZip config/auth locations to ~/tmp first? [y/N]: ") \
            .lower().startswith("y"):
        out, n = backup_zip(backup_paths)
        print(f"Backup: {out} ({n} files)")

    alive = running_processes()
    if alive:
        print(f"\nABORT: these are running: {', '.join(alive)}. "
              f"Quit them first (sqlite/WAL corruption risk).")
        sys.exit(1)

    if ask("\nType BE GONE to execute: ").strip() != "BE GONE":
        print("Aborted — nothing deleted.")
        return

    print("\nDeleting…")
    freed = errors = 0
    for e in plan:
        f, er = delete_paths(sorted(e["paths"].items(), key=lambda kv: -kv[1]))
        freed += f
        errors += er
        run_specs(e["specs"])
    print(f"\nDone. Freed {human_size(freed)}; {errors} errors.")


# ── HTML report ──────────────────────────────────────────────────────────

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
    ap.add_argument("--be-gone", dest="be_gone", action="store_true",
                    help="Interactive: pick harnesses, then delete data, configs+auth, "
                         "or uninstall the whole app")
    ap.add_argument("--no-open", action="store_true", help="Don't open the report in a browser")
    ap.add_argument("--check", action="store_true", help="Run self-test and exit")
    args = ap.parse_args()

    if args.be_gone:
        try:
            be_gone()
        except KeyboardInterrupt:
            print("\nAborted — nothing deleted.")
        return

    if args.check:
        assert human_size(0).endswith("0 B")
        assert human_size(1536 * 1024 * 1024).endswith("1.5 GB")
        assert path_size(Path("/nonexistent-xyz")) == (0, 0)
        assert expand("/nonexistent-xyz/*.tmp") == []
        assert parse_sel("all", 3) == [1, 2, 3]
        assert parse_sel("1,3", 3) == [1, 3]
        assert parse_sel("1-3", 3) == [1, 2, 3]
        assert parse_sel("9", 3) is None
        assert parse_sel("", 3) is None
        assert uninstall_extras("Nope-XYZ") == ([], [])
        assert is_never(HOME / "dot") and is_never(HOME / ".dot")
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
    items = [(r["path"], r["size"]) for r in
             sorted((r for r in rows if r["action"] == "delete"), key=lambda r: -r["size"])]
    freed, errors = delete_paths(items)
    print(f"\nDone. Freed {human_size(freed)}; {errors} errors. Report kept at {report}")


if __name__ == "__main__":
    main()
