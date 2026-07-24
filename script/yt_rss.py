#!/usr/bin/env python3
"""Print the YouTube channel RSS feed URL for a given channel URL or video URL.

Accepts:
  - https://youtu.be/VIDEO_ID
  - https://www.youtube.com/watch?v=VIDEO_ID
  - https://www.youtube.com/channel/UC...
  - https://www.youtube.com/@handle
  - https://www.youtube.com/c/CustomName or /user/Name

With --newsboat, appends the feed to ~/dot/config/newsboat/urls.
"""
import argparse
import os
import re
import sys
import urllib.request

UA = "Mozilla/5.0 (compatible; yt-rss/1.0)"
FEED = "https://www.youtube.com/feeds/videos.xml?channel_id={}"


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=15) as r:
        return r.read().decode("utf-8", errors="replace")


def extract_channel_id(url):
    m = re.search(r"youtube\.com/channel/(UC[\w-]+)", url)
    if m:
        return m.group(1), None
    html = fetch(url)
    cid = (
        re.search(r'"externalId":"(UC[\w-]+)"', html)
        or re.search(r'<meta itemprop="(?:channelId|identifier)" content="(UC[\w-]+)"', html)
        or re.search(r'"channelId":"(UC[\w-]+)"', html)
    )
    if not cid:
        raise SystemExit(f"Could not find channelId at {url}")
    title = re.search(r'"author":"([^"]+)"', html) or re.search(
        r'<meta itemprop="name" content="([^"]+)"', html
    ) or re.search(r"<title>([^<]+?)(?: - YouTube)?</title>", html)
    return cid.group(1), (title.group(1) if title else None)


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("url", help="YouTube channel URL or video URL")
    p.add_argument(
        "--newsboat",
        action="store_true",
        help="Append to ~/dot/config/newsboat/urls",
    )
    args = p.parse_args()

    channel_id, title = extract_channel_id(args.url)
    feed = FEED.format(channel_id)

    if args.newsboat:
        path = os.path.expanduser("~/dot/config/newsboat/urls")
        line = f'{feed} "{title}"\n' if title else f"{feed}\n"
        with open(path) as f:
            if feed in f.read():
                print(f"Already present: {feed}", file=sys.stderr)
                return
        with open(path, "a") as f:
            f.write(line)
        print(f"Added: {line.strip()}")
    else:
        print(feed)
        if title:
            print(f'# "{title}"', file=sys.stderr)


if __name__ == "__main__":
    main()
