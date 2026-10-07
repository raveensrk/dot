# iTerm2 install and settings sync

iTerm2 keeps its settings in one plist. Point it at a folder inside this repo
and the same settings follow you to every machine.

## Sync setup, once per machine

1. `Settings` (`⌘,`) -> `General` -> `Settings` -> tick `Load settings from a custom folder or URL`.
2. Path: `~/dot/config/iterm2`.
3. `Save changes` popup -> `Save changes on quit`. Never `Save changes on quit (Automatic)`:
   it writes on every change, which widens the window for a conflict with another machine.
4. `Save Now` writes the file at once; a quit writes it too.
5. Quit and relaunch iTerm2 so the folder is read at startup.

Wire the redaction filter, once per clone, or git stores the raw file:

```
git -C ~/dot config --local include.path ../.gitconfig
```

## What git stores

iTerm2 writes the file raw. The clean filter
[script/iterm2_prefs_redact](../script/iterm2_prefs_redact) rewrites it on the
way in, so history never holds private data:

1. Only keys iTerm2 itself would sync are kept - the same filter iTerm2 uses
   (`iTermRemotePreferencesKeyIsSyncable`): `NS`/`SU`/`NoSync`/`UK` prefixed keys,
   `Secure Input`, `AppVersion`, `PrefsCustomFolder` and `LoadPrefsFromCustomFolder`
   are dropped.
2. Every `<data>` blob is dropped. Saved AI prompts (`CodeReviewSavedPrompts`) and
   workgroups (`Workgroups`) do not travel; they stay per machine.
3. `/Users/<name>` and `/home/<name>` become `~`.

The working copy stays raw on the machine that owns iTerm2, so iTerm2 reads and
writes exactly what it wrote. `--check` certifies a published copy (a fresh
checkout, or the staged blob), not that working copy.

## Two machines

1. Before launching iTerm2: `git -C ~/dot pull --rebase`.
2. After quitting iTerm2:
   `git -C ~/dot add config/iterm2/com.googlecode.iterm2.plist && git -C ~/dot commit -m "iterm2 prefs" && git -C ~/dot push`.
3. Never edit settings on both machines at once. The file has no merge, only a readable conflict.

## Check

```
script/iterm2_prefs_redact --check ~/dot/config/iterm2/com.googlecode.iterm2.plist
git show :config/iterm2/com.googlecode.iterm2.plist | rg -c "/Users/|<data>" || echo clean
timeout 120 python3 -m pytest tests/test_iterm2_prefs_redact.py
```

## Layouts

1. Build the windows and tabs you want, then `Window` -> `Save Window Arrangement`.
2. It lands in the settings file, so it syncs.
3. On another machine: `Window` -> `Arrangements` -> `Restore Window Arrangement (as Tabs)`.

## Known traps

1. `Load settings from a custom folder or URL` ticked with no folder set leaves a
   warning sign in the pane and loads nothing. Set the folder or untick it.
2. Profile `Working Directory` values arrive as `~`. iTerm2 expands `~` in a
   profile working directory; if a tab ever opens in the wrong place, drop that
   key in the redactor instead of rewriting it.
3. The redacted file is what a second machine reads, so a blob-backed setting
   (saved prompts, workgroups) is absent there until it is set locally.
