---
id: "yp6496jjf3"
title: "Source-control Gmail filters locally"
state: "todo"
due: "2026-11-02"
priority: ""
tag: ["email"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-15"
closed: ""
---

## Plan

1. Export filters with `himalaya gmail settings filters list -a Personal --json` into `~/dot/config/gmail_filters.json`, storing label names instead of label IDs.
2. Write a sync script: create the filters that are only in the file; report filters that are only in Gmail and ask whether to delete them or add them to the file. A changed filter is deleted and created again, because the API has no update.
3. Add `,gmail_filter_add <sender> <action>`, which edits the file and runs the sync. It replaces `,mutt_add_sender_to_spam`.

## Notes

- Gmail filters can't add the SPAM label (the API returns HTTP 400), so "spam" means TRASH.
- Gmail API auth is `,gmail_oauth_token`. The sign-in expires every 7 days while the Google app is in Testing mode.
- iCloud has no filter API, so this is Gmail only.

## Acceptance

- Running the sync on a fresh export changes nothing.
- Adding a sender to the file and running the sync creates the matching Gmail filter.
