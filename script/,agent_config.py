#!/usr/bin/env python3
"""Agent harness config. Preview skill sync or --export shared settings; --apply writes changes."""

import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import tempfile

try:
    import yaml
except ImportError:
    sys.exit("ERROR: PyYAML required. Install it for this Python: python3 -m pip install PyYAML")

SKIP = {".git", "node_modules", ".venv", "venv", "__pycache__", ".cache", "vendor", "dist", "build"}
LOCAL = {"defaultProvider", "defaultModel", "skills", "lastChangelogVersion"}


def short(value):
    return str(value).replace(str(Path.home()) + os.sep, "~/")


def log(action, **fields):
    if action == "error":
        print(f"ERROR: {short(fields['message'])}", file=sys.stderr)
        return
    if action in ("preview", "apply"):
        label = "Plan" if action == "apply" else "Summary"
        print(f"`-- {label}: {fields['globals']} global, {fields['added']} to add, "
              f"{fields['removed']} to remove, {fields['links']} links to migrate")
        return
    label = fields.get("name") or fields.get("path") or fields["source"]
    status = {"register": "ADD", "unlink": "MIGRATE"}.get(action, action.upper())
    print(f"|-- [{status}] {short(label)}")
    details = [(key, fields[key]) for key in ("source", "reason")
               if key in fields and fields[key] != label]
    for index, (key, value) in enumerate(details):
        branch = "`--" if index == len(details) - 1 else "|--"
        print(f"|   {branch} {key.capitalize()}: {short(value)}")


def discover(roots):
    skills = {}
    seen = set()
    for root in roots:
        if not root.is_dir():
            raise ValueError(f"scan root missing: {root}; refusing to prune")

        def fail(err):
            raise err

        for base, dirs, files in os.walk(root, onerror=fail, followlinks=False):
            dirs[:] = sorted(d for d in dirs if d not in SKIP and not Path(base, d).is_symlink())
            if "SKILL.md" not in files:
                continue
            path = Path(base, "SKILL.md")
            if path.is_symlink():
                log("skip", source=str(path), reason="symlinked SKILL.md")
                continue
            source = str(path.parent.resolve())
            if source in seen:
                continue
            seen.add(source)
            lines = path.read_text().splitlines()
            if not lines or lines[0] != "---":
                log("skip", source=source, reason="no frontmatter")
                continue
            try:
                end = lines.index("---", 1)
                data = yaml.safe_load("\n".join(lines[1:end]))
                if not isinstance(data, dict):
                    raise ValueError("frontmatter must be a mapping")
                meta = data.get("metadata", {})
                if not isinstance(meta, dict):
                    raise ValueError("metadata must be a mapping")
                scope = meta.get("scope")
                if scope not in (None, "local", "global"):
                    raise ValueError("metadata.scope must be local or global")
                if scope != "global":
                    log("skip", source=source, reason="not explicitly global")
                    continue
                name = data.get("name", "")
                if not isinstance(name, str) or not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) or len(name) > 64:
                    raise ValueError("invalid skill name")
                if not isinstance(data.get("description"), str) or not data["description"].strip():
                    raise ValueError("global skill needs a description")
            except (ValueError, yaml.YAMLError) as err:
                raise ValueError(f"{path}: {err}") from err
            if name in skills:
                raise ValueError(f"duplicate skill {name}: {skills[name]} and {source}")
            skills[name] = source
    return skills


def load(path):
    if not path.exists():
        return {}
    data = json.loads(path.read_text())
    if not isinstance(data, dict):
        raise ValueError(f"{path}: expected JSON object")
    return data


def strings(data, key, path):
    values = data.get(key, [])
    if not isinstance(values, list) or any(not isinstance(v, str) for v in values):
        raise ValueError(f"{path}: {key} must be a list of strings")
    return values


def atomic(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        if path.exists():
            os.chmod(name, path.stat().st_mode & 0o777)
        os.replace(name, path)
        fd = os.open(path.parent, os.O_RDONLY)
        try:
            os.fsync(fd)
        finally:
            os.close(fd)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def dump(data):
    return json.dumps(data, indent=2, ensure_ascii=False) + "\n"


def export(agent, apply=False):
    source = (agent / "settings.json").resolve()
    target = (agent / "settings.example.json").resolve()
    if source == target:
        raise ValueError("live settings and template must be different files")
    before = source.read_text()  # Missing live settings must not empty the template.
    cfg = json.loads(before)
    if not isinstance(cfg, dict):
        raise ValueError(f"{source}: expected JSON object")
    saved = target.read_text() if target.exists() else None
    old = load(target)
    shared = {key: value for key, value in cfg.items() if key not in LOCAL}
    keys = sorted(key for key in old.keys() | shared.keys()
                  if key not in old or key not in shared or old[key] != shared[key])
    print("Pi settings - export plan" if apply else "Pi settings - export preview (no changes)")
    print(f"|-- Source: {short(source)}")
    print(f"|-- Template: {short(target)}")
    print(f"|-- Local only: {', '.join(sorted(LOCAL))}")
    for key in keys:
        status = "REMOVE" if key not in shared else "ADD" if key not in old else "UPDATE"
        print(f"|-- [{status}] {key}")
    changed = bool(keys) or saved is None
    print(f"`-- {len(keys)} changed keys; " + ("template will be written" if changed else "already up to date"))
    if not apply or not changed:
        return
    if source.read_text() != before or (target.read_text() if target.exists() else None) != saved:
        raise ValueError("settings or template changed during export; rerun")
    if saved is not None:
        atomic(target.with_name(target.name + ".bak.skills"), saved)
    atomic(target, dump(shared))
    print("Template exported. Live settings unchanged.")


def sync(roots, agent, shared, state, apply=False):
    # Resolve settings symlinks rather than replacing the link itself.
    settings = (agent / "settings.json").resolve()
    print("Pi skills - apply plan" if apply else "Pi skills - preview (no changes)")
    print(f"|-- Settings: {short(settings)}")
    before = settings.read_text() if settings.exists() else None
    cfg = load(settings)
    old = strings(cfg, "skills", settings)
    ledger = load(state)
    if ledger and ledger.get("settings") != str(settings):
        raise ValueError(f"{state}: settings path mismatch")
    owned = set(strings(ledger, "paths", state))
    wanted = discover(roots)
    desired = set(wanted.values())
    removed = owned - desired
    paths = [p for p in old if p not in removed]

    def resolve(value):
        # Preserve Pi resource filters; do not mistake an exclusion for an install.
        if value.startswith(("!", "-")):
            return None
        path = Path(value.removeprefix("+")).expanduser()
        if not path.is_absolute():
            path = agent / path
        return str(path.resolve())

    present = {resolve(p) for p in paths}
    added = sorted(desired - present)
    paths.extend(added)
    # A manually rewritten spelling is now user-owned; do not adopt aliases.
    managed = (owned & set(paths)) | set(added)
    links = []
    if shared.exists():
        for link in sorted(shared.iterdir()):
            if link.is_symlink() and str(link.resolve()) in desired:
                links.append((link, link.resolve()))
    for name, source in sorted(wanted.items()):
        log("register" if source in added else "keep", name=name, source=source, destination=str(settings))
    for path in sorted(removed & set(old)):
        log("remove", source=path, destination=str(settings), reason="previously managed, no longer global")
    for link, target in links:
        log("unlink", path=str(link), source=str(target), reason="migrate to native Pi path")
    payload = {"settings": str(settings), "paths": sorted(managed)}
    changed = paths != old
    log("apply" if apply else "preview", globals=len(wanted), added=len(added), removed=len(set(old) & removed), links=len(links))
    if not apply:
        return
    if (settings.read_text() if settings.exists() else None) != before:
        raise ValueError("Pi settings changed during scan; rerun")
    if changed:
        if before is not None:
            atomic(settings.with_name(settings.name + ".bak.skills"), before)
        # Write ownership ahead of settings. Interrupted runs can safely retry;
        # never claim pre-existing manual entries. Retain old ownership until commit.
        atomic(state, dump({"settings": str(settings), "paths": sorted(owned | managed)}))
        cfg["skills"] = paths
        atomic(settings, dump(cfg))
    if load(state) != payload:
        atomic(state, dump(payload))
    # Only migrate after both native registration and ownership are durable.
    for link, target in links:
        if not link.is_symlink() or link.resolve() != target:
            raise ValueError(f"link changed during sync: {link}; leaving it untouched")
        link.unlink()
    print("Sync complete. Run /reload in Pi.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="apply the skill sync or settings export")
    parser.add_argument("--export", action="store_true", help="export shared settings to settings.example.json instead of syncing skills")
    args = parser.parse_args()
    home = Path.home()
    agent = Path(os.environ.get("PI_CODING_AGENT_DIR", str(home / ".pi/agent"))).expanduser().resolve()
    key = hashlib.sha256(str(agent).encode()).hexdigest()[:16]
    state = Path(os.environ.get("XDG_STATE_HOME", str(home / ".local/state"))).expanduser() / "pi_skills" / f"{key}.json"
    try:
        if not args.apply:
            if args.export:
                export(agent)
                return
            sync([home / "dot", home / "repos"], agent, home / ".agents/skills", state)
            return
        state.parent.mkdir(parents=True, exist_ok=True)
        with (state.parent / "sync.lock").open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            if args.export:
                export(agent, apply=True)
                return
            sync([home / "dot", home / "repos"], agent, home / ".agents/skills", state, apply=True)
    except (OSError, ValueError) as err:
        log("error", message=str(err))
        sys.exit(1)


if __name__ == "__main__":
    main()
