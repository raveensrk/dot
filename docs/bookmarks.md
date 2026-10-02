# Bookmarks

`script/bookmark` is the one writer for every bookmark file on this machine. It
replaced the old three-line `sort ~/bookmarks.txt | fzf | xargs open` launcher,
which had been broken since `~/bookmarks.txt` went away, and the duplicate
`bookmark3`.

## The protocol

A file is a **sink** only if it describes itself: YAML front matter with a
`bookmarks:` key. A file without one is invisible to `add`, which is how the
redirect stub `~/repos/personal/BOOKMARKS.md` and the study note
`~/repos/work/deck/verification/peakrdl/bookmark.md` were sorted out without a
hardcoded list anywhere.

```markdown
---
bookmarks:
  scope: work and technical links - agents, FPGA, electronics, AI, reading
  default_section: Read Later
  order: newest-last
---
```

- `scope` is the routing sentence. Jev reads it and nothing else of the file, so
  it should say what belongs there rather than what the file is called.
- `sections` is deliberately absent: the `##` headings already are the sections,
  and a copy in the metadata would drift from them.
- `default_section` is created at the end of the file when missing. Any other
  missing section needs `--new-section`, because inventing a category is a
  judgement call, not a deterministic write.
- `order` is `newest-last` (append at the end of the section) or `newest-first`
  (insert under the heading).

Other front matter keys are preserved byte for byte: the published page
`~/repos/raveenkumar.xyz/raveenkumar.xyz/content/library/Bookmarks.md` keeps its
`title`, `description`, `tags` and `date` when the block is written.

## Flow

Three diagrams, drawn from the same mermaid source that renders in any markdown
viewer. Re-render them with the offline mermaid-cli that is already in the npx
cache:

```
node ~/.npm/_npx/668c188756b835f3/node_modules/@mermaid-js/mermaid-cli/src/cli.js \
  -i FILE.mmd -o FILE.svg -p /Users/raveen_kumar_personal/tmp/mmdc_puppeteer.json -b "#f7f8fa"
```

### 1. Which command runs, and what counts as a sink

```mermaid
flowchart TB
    cmd(["bookmark &lt;url&gt;"]) --> dispatch{"first word"}

    dispatch -->|list| ls["list: sinks, scopes, counts"]
    dispatch -->|check| ck["check: duplicates, scope, order"]
    dispatch -->|describe| ds["describe: write front matter"]
    dispatch -->|"a url, or nothing"| walk

    subgraph discovery["discovery - runs on every command"]
        direction TB
        walk["walk ~/repos and ~/iCloud"] --> isname{"bookmark*.md ?"}
        isname -->|no| skip["ignored"]
        isname -->|yes| isfm{"bookmarks: front matter ?"}
        isfm -->|no| skip2["ignored: the stub, a study note,<br/>anything that does not describe itself"]
        isfm -->|yes| sink["a sink"]
    end

    sink --> add(["continue in part 2"])

    classDef entry fill:#E8F0FE,stroke:#4285F4,color:#0b2545,stroke-width:2px;
    classDef decision fill:#FFF4E5,stroke:#F5A623,color:#3a2a00;
    classDef good fill:#EAF7EE,stroke:#27AE60,color:#0d3b1e;
    classDef bad fill:#FDECEA,stroke:#E74C3C,color:#4a0f08;

    class cmd,ls,ck,ds,add entry;
    class dispatch,isname,isfm decision;
    class sink good;
    class skip,skip2 bad;
    style discovery fill:#F3E8FD,stroke:#8E44AD,color:#2c0a3e
```

### 2. The checks and the routing

```mermaid
flowchart TB
    start(["a sink was found"]) --> scheme{"http(s) url ?"}
    scheme -->|no| stop1["refuse, exit 2"]
    scheme -->|yes| dup{"already in any sink ?"}
    dup -->|yes| stop2["refuse: file:line, exit 1<br/>--force overrides"]
    dup -->|no| title["title: --title, else<br/>curl --max-time 8, else url tail"]

    title --> route
    subgraph routing["which sink, which section"]
        direction TB
        route{"--to FILE ?"}
        route -->|yes| chosen["target decided"]
        route -->|no| jev{"Jev: which sink ?<br/>0.6 or better"}
        jev -->|yes| jev2{"Jev: which section ?<br/>0.6 or better"}
        jev -->|no| tty{"terminal attached ?"}
        tty -->|yes| fzf["fzf picker"]
        tty -->|no| stop3["refuse: print the candidates, exit 2"]
        jev2 -->|yes| chosen
        jev2 -->|no| fallback["default_section"]
        fallback --> chosen
    end

    classDef entry fill:#E8F0FE,stroke:#4285F4,color:#0b2545,stroke-width:2px;
    classDef decision fill:#FFF4E5,stroke:#F5A623,color:#3a2a00;
    classDef good fill:#EAF7EE,stroke:#27AE60,color:#0d3b1e;
    classDef bad fill:#FDECEA,stroke:#E74C3C,color:#4a0f08;

    class start,title entry;
    class scheme,dup,route,jev,jev2,tty decision;
    class chosen,fzf,fallback good;
    class stop1,stop2,stop3 bad;
    style routing fill:#F3E8FD,stroke:#8E44AD,color:#2c0a3e
```

### 3. Placement and the write

```mermaid
flowchart TB
    chosen(["target decided"]) --> place

    subgraph placement["where the line lands"]
        direction TB
        place{"section exists ?"}
        place -->|"no, and it is default_section"| create["create it at end of file"]
        place -->|"no, and it is anything else"| stop4["refuse: --new-section"]
        place -->|yes| order{"order"}
        order -->|newest-last| append["append at end of section"]
        order -->|newest-first| prepend["insert under the heading"]
    end

    append --> dry{"--dry-run ?"}
    prepend --> dry
    create --> dry
    dry -->|yes| show["print the line, write nothing"]
    dry -->|no| save["write the file<br/>print file :: section :: line"]

    classDef entry fill:#E8F0FE,stroke:#4285F4,color:#0b2545,stroke-width:2px;
    classDef decision fill:#FFF4E5,stroke:#F5A623,color:#3a2a00;
    classDef good fill:#EAF7EE,stroke:#27AE60,color:#0d3b1e;
    classDef bad fill:#FDECEA,stroke:#E74C3C,color:#4a0f08;

    class chosen,save,show entry;
    class place,order,dry decision;
    class append,prepend,create good;
    class stop4 bad;
    style placement fill:#F3E8FD,stroke:#8E44AD,color:#2c0a3e
```

## Commands

| Command | What it does |
|---|---|
| `bookmark URL` | Add it. Routing below |
| `bookmark` | fzf over every sink and section, opens the pick |
| `bookmark list` | The sinks, their scope, link and section counts (`--json` for scripts) |
| `bookmark check` | Validate the protocol across every sink; exit 1 on findings |
| `bookmark describe FILE --scope '...'` | Write or update the front matter |

Flags for `add`: `--to FILE`, `--section NAME`, `--title TEXT`,
`--new-section`, `--force`, `--no-jev`, `--dry-run`, `--json`.

## Routing

1. `--to` (with `--section`) wins outright.
2. Otherwise Jev, in two choices: the sink, then the section inside it. Jev sees
   one sink's scope and section names at a time - accuracy falls with a large
   state, and a single 24-option choice is a coin toss.
3. Only at 0.6 confidence or better. Below that: fzf when a terminal is
   attached, otherwise it stops and prints the candidates.
4. The same routing applies whether the command comes from a shell or from an
   agent; an agent has no terminal, so its two paths are `--to` and Jev.

A live example, run as a dry run:

```
bookmark https://www.meditation.com/ --dry-run
dry run: would add to ~/iCloud/notes/bookmarks.md under 'Meditation':
  - [Meditation.com: The place to Discover the Impact of Meditation](https://www.meditation.com/)
```

## Duplicates

`add` refuses a URL that already sits in any sink, printing the file and line,
and `--force` overrides. The comparison ignores scheme, `www.` and a trailing
slash, so `http://example.com/x/` and `https://www.example.com/x` are one link.

## Tests

```
python3 -m pytest tests/test_bookmark.py
```

15 cases, offline: Jev is never called (the tests pass `--no-jev`), the sinks
are a temporary tree via `BOOKMARK_ROOTS`. They cover discovery by front matter,
the duplicate refusal and `--force`, both orderings, default-section creation,
the refusal of an invented section, `--dry-run` writing nothing, and that
`describe` leaves other front matter keys untouched.

## Known ceilings

- `order` is per file, not per section, so `## Reading Log` in
  `~/repos/work/bookmarks.md` appends at the end despite reading newest first.
- A link added to the published page is published. It is the only sink whose
  content is public.
- Jev never routes to a sink whose `scope` is empty; `bookmark check` flags that
  as a finding.
