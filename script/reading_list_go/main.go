// reading_list - manage the links to read, one reading_list.yaml per repo.
//
// Each repo keeps its own reading_list.yaml at its root: a YAML list with one
// entry per line, so a file stays greppable and diffs stay one line per link:
//
//   - {state: to_read, rating: null, tag: [pi], url: "https://...", title: "..."}
//
// state is to_read or read; rating is 1-10 once read, else null; tag is a list
// of lowercase singular words. Run through ~/dot/script/,reading_list, which
// rebuilds this program when its source changes.
package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"text/tabwriter"

	"gopkg.in/yaml.v3"
)

const fileName = "reading_list.yaml"

const header = "# reading_list.yaml - one link per line: state to_read|read, rating 1-10 once read, tag, url, title\n"

const usage = `usage: ,reading_list <command> [options]

Manage the links to read: one reading_list.yaml per repo, one line per link.

commands:
  list [-s STATE] [-t TAG] [-r REPO]   show links (default: to_read, every repo)
  files                                print the path of every reading_list.yaml
  add URL [TITLE...] [-t TAG]...       add a to_read link to this repo's list
  done REF [-r N]                      mark read, optionally rated 1-10
  tag REF TAG...                       set a link's tags (replaces them)
  help                                 this text

options:
  -s, --state S   to_read (default), read, or all
  -t, --tag T     a tag: lowercase letters, digits and _, singular
  -r, --repo R    list: only this repo; done: the rating 1-10
  -h, --help      this text

REF is any part of a URL, matching exactly one link across every repo.
add writes to the reading_list.yaml of the git repo you are in, else
~/repos/work. Lists are found anywhere under ~, following links such as
~/iCloud, skipping hidden folders, ~/Library and build folders. Found paths
are remembered for a day; files searches again.

examples:
  ,reading_list list -t pi
  ,reading_list add https://example.com/post "A good post" -t ai
  ,reading_list done example.com/post -r 8
`

// entry is one link. Field order here is the order written to the file.
type entry struct {
	State  string   `yaml:"state"`
	Rating *int     `yaml:"rating"`
	Tag    []string `yaml:"tag"`
	URL    string   `yaml:"url"`
	Title  string   `yaml:"title"`
}

// list is one repo's reading_list.yaml.
type list struct {
	repo    string
	path    string
	entries []entry
}

var tagRule = regexp.MustCompile(`^[a-z0-9_]+$`)

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, ",reading_list:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 0 || args[0] == "help" || args[0] == "-h" || args[0] == "--help" {
		fmt.Print(usage)
		return nil
	}
	cmd, rest := args[0], args[1:]
	opts, words, err := parseFlags(rest)
	if err != nil {
		return err
	}
	if opts.help {
		fmt.Print(usage)
		return nil
	}
	switch cmd {
	case "list":
		return cmdList(opts)
	case "files":
		return cmdFiles()
	case "add":
		return cmdAdd(words, opts)
	case "done":
		return cmdDone(words, opts)
	case "tag":
		return cmdTag(words)
	}
	return fmt.Errorf("unknown command %q; try: ,reading_list help", cmd)
}

type options struct {
	state, repo, rating string
	tags                []string
	help                bool
}

// parseFlags splits ARGS into options and plain words. -r means --repo for
// list and the rating for done, so it is kept raw and read by the command.
func parseFlags(args []string) (options, []string, error) {
	var o options
	var words []string
	for i := 0; i < len(args); i++ {
		a := args[i]
		next := func() (string, error) {
			if i+1 >= len(args) {
				return "", fmt.Errorf("%s needs a value", a)
			}
			i++
			return args[i], nil
		}
		var err error
		switch a {
		case "-h", "--help":
			o.help = true
		case "-s", "--state":
			o.state, err = next()
		case "-t", "--tag":
			var t string
			t, err = next()
			o.tags = append(o.tags, t)
		case "-r", "--repo", "--rating":
			o.repo, err = next()
			o.rating = o.repo
		default:
			if strings.HasPrefix(a, "-") && len(a) > 1 {
				return o, nil, fmt.Errorf("unknown option %s; try: ,reading_list help", a)
			}
			words = append(words, a)
		}
		if err != nil {
			return o, nil, err
		}
	}
	for _, t := range o.tags {
		if !tagRule.MatchString(t) {
			return o, nil, fmt.Errorf("tag %q: use lowercase letters, digits and _ (e.g. %s)", t,
				strings.Trim(regexp.MustCompile(`[^a-z0-9_]+`).ReplaceAllString(strings.ToLower(t), "_"), "_"))
		}
	}
	return o, words, nil
}

// allLists reads every reading_list.yaml under ~, sorted by repo.
func allLists() ([]*list, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}
	paths := listPaths(home)
	var lists []*list
	for _, p := range paths {
		l, err := load(p)
		if errors.Is(err, os.ErrNotExist) {
			continue
		}
		if err != nil {
			return nil, err
		}
		lists = append(lists, l)
	}
	sort.Slice(lists, func(i, j int) bool { return lists[i].repo < lists[j].repo })
	return lists, nil
}

func load(path string) (*list, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	l := &list{repo: filepath.Base(filepath.Dir(path)), path: path}
	if err := yaml.Unmarshal(data, &l.entries); err != nil {
		return nil, fmt.Errorf("%s: %w", path, err)
	}
	for i, e := range l.entries {
		if err := e.check(); err != nil {
			return nil, fmt.Errorf("%s entry %d: %w", path, i+1, err)
		}
	}
	return l, nil
}

func (e entry) check() error {
	if e.State != "to_read" && e.State != "read" {
		return fmt.Errorf("state %q: use to_read or read", e.State)
	}
	if e.Rating != nil && (*e.Rating < 1 || *e.Rating > 10) {
		return fmt.Errorf("rating %d: use 1-10", *e.Rating)
	}
	if !strings.HasPrefix(e.URL, "http://") && !strings.HasPrefix(e.URL, "https://") {
		return fmt.Errorf("url %q: must start with http:// or https://", e.URL)
	}
	return nil
}

// save writes L back, one flow-style entry per line, via a temp file and a
// rename so a crash never leaves half a list.
func (l *list) save() error {
	var b strings.Builder
	b.WriteString(header)
	for _, e := range l.entries {
		rating := "null"
		if e.Rating != nil {
			rating = strconv.Itoa(*e.Rating)
		}
		tags := e.Tag
		if tags == nil {
			tags = []string{}
		}
		fmt.Fprintf(&b, "- {state: %s, rating: %s, tag: [%s], url: %s, title: %s}\n",
			e.State, rating, strings.Join(tags, ", "), quote(e.URL), quote(e.Title))
	}
	tmp := l.path + ".tmp"
	if err := os.WriteFile(tmp, []byte(b.String()), 0o644); err != nil {
		return err
	}
	return os.Rename(tmp, l.path)
}

// quote is a JSON string, which is also a valid YAML double-quoted scalar.
func quote(s string) string {
	q, _ := json.Marshal(s)
	return string(q)
}

func cmdList(o options) error {
	state := o.state
	if state == "" {
		state = "to_read"
	}
	if state != "to_read" && state != "read" && state != "all" {
		return fmt.Errorf("state %q: use to_read, read or all", state)
	}
	lists, err := allLists()
	if err != nil {
		return err
	}
	home, _ := os.UserHomeDir()
	// tabwriter pads every column to its longest cell; nothing is cut.
	out := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	shown := 0
	for _, l := range lists {
		if o.repo != "" && l.repo != o.repo {
			continue
		}
		path := strings.Replace(l.path, home, "~", 1)
		for _, e := range l.entries {
			if state != "all" && e.State != state {
				continue
			}
			if !hasTags(e, o.tags) {
				continue
			}
			rating := "-"
			if e.Rating != nil {
				rating = strconv.Itoa(*e.Rating)
			}
			tags := strings.Join(e.Tag, ",")
			if tags == "" {
				tags = "-"
			}
			fmt.Fprintf(out, "%s\t%s\t%s\t%s\t%s\t%s\n", path, e.State, rating, tags, title(e), e.URL)
			shown++
		}
	}
	out.Flush()
	fmt.Fprintf(os.Stderr, "%d links\n", shown)
	return nil
}

func title(e entry) string {
	if e.Title != "" {
		return e.Title
	}
	return e.URL
}

func hasTags(e entry, want []string) bool {
	for _, w := range want {
		found := false
		for _, t := range e.Tag {
			if t == w {
				found = true
			}
		}
		if !found {
			return false
		}
	}
	return true
}

func cmdAdd(words []string, o options) error {
	if len(words) == 0 {
		return errors.New("add needs a URL: ,reading_list add URL [TITLE...] [-t TAG]")
	}
	e := entry{State: "to_read", Tag: o.tags, URL: words[0], Title: strings.Join(words[1:], " ")}
	if err := e.check(); err != nil {
		return err
	}
	lists, err := allLists()
	if err != nil {
		return err
	}
	for _, l := range lists {
		for _, have := range l.entries {
			if have.URL == e.URL {
				return fmt.Errorf("already listed in %s (%s)", l.repo, have.State)
			}
		}
	}
	path, err := targetPath()
	if err != nil {
		return err
	}
	if _, err := os.Stat(filepath.Dir(path)); err != nil {
		return fmt.Errorf("no repo at %s to add to; cd into a repo and run add again", filepath.Dir(path))
	}
	l, err := load(path)
	if errors.Is(err, os.ErrNotExist) {
		l, err = &list{repo: filepath.Base(filepath.Dir(path)), path: path}, nil
		// a new file: the remembered paths no longer cover every list
		if home, herr := os.UserHomeDir(); herr == nil {
			forgetPaths(home)
		}
	}
	if err != nil {
		return err
	}
	l.entries = append(l.entries, e)
	if err := l.save(); err != nil {
		return err
	}
	fmt.Printf("added to %s: %s\n", l.repo, title(e))
	return nil
}

// targetPath is the reading_list.yaml of the git repo around the working
// directory, else ~/repos/work's.
func targetPath() (string, error) {
	if out, err := exec.Command("git", "rev-parse", "--show-toplevel").Output(); err == nil {
		return filepath.Join(strings.TrimSpace(string(out)), fileName), nil
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, "repos", "work", fileName), nil
}

// find resolves REF, any part of a URL, to exactly one link.
func find(ref string) (*list, int, error) {
	lists, err := allLists()
	if err != nil {
		return nil, 0, err
	}
	var hits []string
	var hitList *list
	hitIndex := -1
	// An exact URL wins even when it is also part of a longer one.
	for _, l := range lists {
		for i, e := range l.entries {
			if e.URL == ref {
				return l, i, nil
			}
		}
	}
	for _, l := range lists {
		for i, e := range l.entries {
			if strings.Contains(e.URL, ref) {
				hits = append(hits, fmt.Sprintf("  %s: %s", l.repo, e.URL))
				hitList, hitIndex = l, i
			}
		}
	}
	switch len(hits) {
	case 0:
		return nil, 0, fmt.Errorf("no link matches %q; try: ,reading_list list -s all", ref)
	case 1:
		return hitList, hitIndex, nil
	}
	return nil, 0, fmt.Errorf("%q matches %d links; use more of the URL:\n%s", ref, len(hits), strings.Join(hits, "\n"))
}

func cmdDone(words []string, o options) error {
	if len(words) != 1 {
		return errors.New("done needs one REF: ,reading_list done REF [-r 1-10]")
	}
	l, i, err := find(words[0])
	if err != nil {
		return err
	}
	l.entries[i].State = "read"
	if o.rating != "" {
		n, err := strconv.Atoi(o.rating)
		if err != nil || n < 1 || n > 10 {
			return fmt.Errorf("rating %q: use a whole number 1-10", o.rating)
		}
		l.entries[i].Rating = &n
	}
	if err := l.save(); err != nil {
		return err
	}
	fmt.Printf("read in %s: %s\n", l.repo, title(l.entries[i]))
	return nil
}

func cmdTag(words []string) error {
	if len(words) < 2 {
		return errors.New("tag needs a REF and tags: ,reading_list tag REF TAG...")
	}
	for _, t := range words[1:] {
		if !tagRule.MatchString(t) {
			return fmt.Errorf("tag %q: use lowercase letters, digits and _", t)
		}
	}
	l, i, err := find(words[0])
	if err != nil {
		return err
	}
	l.entries[i].Tag = words[1:]
	if err := l.save(); err != nil {
		return err
	}
	fmt.Printf("tagged in %s: %s [%s]\n", l.repo, title(l.entries[i]), strings.Join(words[1:], ", "))
	return nil
}

func cmdFiles() error {
	refresh = true
	lists, err := allLists()
	if err != nil {
		return err
	}
	home, _ := os.UserHomeDir()
	for _, l := range lists {
		fmt.Println(strings.Replace(l.path, home, "~", 1))
	}
	return nil
}
