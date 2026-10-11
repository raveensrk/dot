package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"strconv"
	"strings"
	"sync"
	"text/tabwriter"
	"unicode"
)

// Metric is one row of the show table: a `models benchmarks show --json` key.
type Metric struct {
	Label, Key, Format string
}

// Rows of the show table, in print order. Scores in 0-1 print as percent.
var metrics = []Metric{
	{"Intelligence index", "intelligence_index", "exact"},
	{"Coding index", "coding_index", "exact"},
	{"Math index", "math_index", "exact"},
	{"MMLU-Pro %", "mmlu_pro", "pct"},
	{"GPQA %", "gpqa", "pct"},
	{"HLE %", "hle", "pct"},
	{"LiveCodeBench %", "livecodebench", "pct"},
	{"SciCode %", "scicode", "pct"},
	{"IFBench %", "ifbench", "pct"},
	{"LCR %", "lcr", "pct"},
	{"Terminal-Bench Hard %", "terminalbench_hard", "pct"},
	{"tau2 %", "tau2", "pct"},
	{"AIME 25 %", "aime_25", "pct"},
	{"$ input / 1M", "price_input", "price"},
	{"$ output / 1M", "price_output", "price"},
	{"$ blended / 1M", "price_blended", "price"},
	{"Output tok/s", "output_tps", "exact"},
	{"TTFT s", "ttft", "exact"},
	{"Context window", "context_window", "tokens"},
	{"Released", "release_date", "%s"},
}

// Rows highlighted by default; --hl or AI_BENCH_HIGHLIGHT replaces the list.
const highlight = "intelligence index,output tok/s,ttft s"

// Bold yellow on, and reset: ANSI SGR codes.
const (
	bright = "\x1b[1;33m"
	reset  = "\x1b[0m"
)

// show prints every benchmark of the variants matching each MODEL[:EFFORTS],
// one column per model and effort. The effort is the first part of the variant tag:
// "Max, Default Fallback" -> max; no tag -> default.
func show(args []string) {
	set := flag.NewFlagSet("show", flag.ExitOnError)
	set.Usage = func() { fmt.Fprint(os.Stderr, usage) }
	effort := set.String("e", "", "efforts, comma separated")
	asJSON := set.Bool("json", false, "JSON output")
	hl := highlight
	if env, ok := os.LookupEnv("AI_BENCH_HIGHLIGHT"); ok {
		hl = env
	}
	marks := set.String("hl", hl, "rows to highlight, comma separated")

	// Flags may come before or after MODEL: show opus -e high
	var words []string
	for len(args) > 0 {
		set.Parse(args)
		args = set.Args()
		if len(args) > 0 {
			words, args = append(words, args[0]), args[1:]
		}
	}
	if len(words) == 0 {
		set.Usage()
		os.Exit(2)
	}

	var list []map[string]any
	// The CLI's --search is a raw substring, so "gpt-5.6-sol" misses slug
	// gpt-5-6-sol. Match here instead, on slugs and names in one dashed form.
	if err := json.Unmarshal(run("models", "benchmarks", "list", "--json"), &list); err != nil {
		fmt.Fprintln(os.Stderr, "error: parse models benchmarks list:", err)
		os.Exit(1)
	}

	// Each word is MODEL or MODEL:EFFORTS, e.g. "opus 5.5:max,low"; a word
	// without a colon takes -e, and no efforts at all means every effort.
	// Columns follow word order; a variant asked for twice prints once.
	var slugs []string
	seen := map[string]bool{}
	for _, word := range words {
		query, efforts := word, *effort
		if at := strings.LastIndex(word, ":"); at >= 0 {
			query, efforts = word[:at], word[at+1:]
		}

		want := map[string]bool{}
		for _, e := range strings.Split(strings.ToLower(efforts), ",") {
			if e = strings.TrimSpace(e); e != "" {
				want[e] = true
			}
		}

		hits := 0
		for _, v := range list {
			slug := fmt.Sprint(v["slug"])
			hit := strings.Contains(dash(slug), dash(query)) || strings.Contains(dash(v["name"]), dash(query))
			if !hit || (len(want) > 0 && !want[level(v["name"])]) {
				continue
			}
			hits++
			if !seen[slug] {
				seen[slug] = true
				slugs = append(slugs, slug)
			}
		}
		if hits == 0 {
			fmt.Fprintf(os.Stderr, "error: no benchmark entry matches %q (effort %q)\n", query, efforts)
			os.Exit(1)
		}
	}

	// `list` has only the sort column; fetch each variant's full entry in parallel.
	full := make([]map[string]any, len(slugs))
	var wg sync.WaitGroup
	for i, slug := range slugs {
		wg.Add(1)
		go func() {
			defer wg.Done()
			fetch(slug, &full[i])
		}()
	}
	wg.Wait()

	if *asJSON {
		out := json.NewEncoder(os.Stdout)
		out.SetIndent("", "  ")
		out.Encode(full)
		return
	}

	// Table: one row per metric, one column per variant, headed "Model / effort".
	// It goes to a buffer first: color codes inside cells would throw off
	// tabwriter's widths, so highlighted rows are colored as whole lines after.
	var buf strings.Builder
	tab := tabwriter.NewWriter(&buf, 0, 0, 2, ' ', tabwriter.AlignRight)
	head := []string{"Metric"}
	for _, v := range full {
		// "Claude Opus 5.5 / max"; a name whose tag is no effort, like
		// "GPT-4o (Nov '24)", is shown whole so the column stays unambiguous.
		label := fmt.Sprintf("%v / %s", v["display_name"], level(v["name"]))
		if level(v["name"]) == "default" {
			label = fmt.Sprint(v["name"])
		}
		head = append(head, label)
	}
	fmt.Fprintln(tab, strings.Join(head, "\t")+"\t")
	for _, m := range metrics {
		row := []string{m.Label}
		for _, v := range full {
			row = append(row, cell(v[m.Key], m.Format))
		}
		fmt.Fprintln(tab, strings.Join(row, "\t")+"\t")
	}
	tab.Flush()

	// Color only on a terminal, and never under NO_COLOR (no-color.org).
	info, _ := os.Stdout.Stat()
	_, plain := os.LookupEnv("NO_COLOR")
	color := !plain && info != nil && info.Mode()&os.ModeCharDevice != 0

	lines := strings.Split(strings.TrimSuffix(buf.String(), "\n"), "\n")
	for i, line := range lines {
		// Line 0 is the header; line i is metrics[i-1].
		if color && i > 0 && marked(metrics[i-1], *marks) {
			line = bright + line + reset
		}
		fmt.Println(line)
	}
}

// marked reports whether M matches an item of LIST (comma separated) by label
// or JSON key, ignoring case and punctuation: "intel", "tok/s", "output_tps".
func marked(m Metric, list string) bool {
	for _, item := range strings.Split(list, ",") {
		item = dash(item)
		if item != "" && (strings.Contains(dash(m.Label), item) || strings.Contains(dash(m.Key), item)) {
			return true
		}
	}
	return false
}

// dash lowercases S and joins its letter/digit runs with "-":
// "GPT-5.6 Sol" -> "gpt-5-6-sol".
func dash(s any) string {
	return strings.Join(strings.FieldsFunc(strings.ToLower(fmt.Sprint(s)), func(r rune) bool {
		return !unicode.IsLetter(r) && !unicode.IsDigit(r)
	}), "-")
}

// level returns the effort from a benchmark name:
// "Claude Opus 5.5 (Xhigh, Default Fallback)" -> "xhigh". A tag that is no
// effort, like "(Nov '24)" or "(Preview)", and no tag at all give "default".
func level(name any) string {
	s := fmt.Sprint(name)
	open := strings.LastIndex(s, "(")
	if open < 0 {
		return "default"
	}
	tag := strings.TrimSuffix(s[open+1:], ")")
	word := strings.ToLower(strings.TrimSpace(strings.Split(tag, ",")[0]))
	if !efforts[word] {
		return "default"
	}
	return word
}

// Effort words a variant tag can start with.
var efforts = map[string]bool{
	"max": true, "xhigh": true, "high": true, "medium": true, "low": true,
	"minimal": true, "reasoning": true, "non-reasoning": true,
}

// fetch decodes `models benchmarks show SLUG --json` into OUT, exiting 1 on
// unparsable output rather than leaving a silently blank column.
func fetch(slug string, out any) {
	slots <- struct{}{}
	defer func() { <-slots }()
	if err := json.Unmarshal(run("models", "benchmarks", "show", slug, "--json"), out); err != nil {
		fmt.Fprintf(os.Stderr, "error: parse models benchmarks show %s: %v\n", slug, err)
		os.Exit(1)
	}
}

// cell formats one value exactly as the source gives it, never rounded;
// "-" when missing, "pct" turns 0.846666666666667 into 84.6666666666667.
func cell(v any, format string) string {
	if v == nil {
		return "-"
	}
	f, ok := v.(float64)
	if !ok {
		return fmt.Sprint(v)
	}
	if format == "tokens" {
		return tokens(f)
	}
	if format == "price" {
		return price(&f)
	}
	if format == "pct" {
		return percent(f)
	}
	return exact(f)
}

// exact prints F with the fewest digits that read back as the same number,
// so a source value of 97.361 prints 97.361 and 4.0 prints 4.
func exact(f float64) string {
	return strconv.FormatFloat(f, 'f', -1, 64)
}

// percent moves the decimal point of F's exact digits two places right, as
// text: f*100 in floating point would print 0.614 as 61.400000000000006.
func percent(f float64) string {
	s, sign := exact(f), ""
	if strings.HasPrefix(s, "-") {
		s, sign = s[1:], "-"
	}
	whole, frac, _ := strings.Cut(s, ".")
	frac += strings.Repeat("0", max(0, 2-len(frac)))
	whole = strings.TrimLeft(whole+frac[:2], "0")
	if whole == "" {
		whole = "0"
	}
	if frac = frac[2:]; frac != "" {
		return sign + whole + "." + frac
	}
	return sign + whole
}

// tokens writes a context size short: 1000000 -> 1M, 131072 -> 128K,
// 200000 -> 200K, 128000 -> 128K. Decimal first; only a size that is not a
// whole thousand but is a multiple of 1024 (131072 = 128 * 1024) counts in binary.
func tokens(n float64) string {
	unit := 1000.0
	if int64(n)%1000 != 0 && int64(n)%1024 == 0 {
		unit = 1024
	}
	for _, suffix := range []string{"", "K", "M"} {
		if n < unit || suffix == "M" {
			return strconv.FormatFloat(n, 'f', -1, 64) + suffix
		}
		n /= unit
	}
	return ""
}

// price formats a $/1M price; 0 prints "-", because the source uses 0 for
// "no price published" (252 of 697 entries, claude-2 among them), not free.
func price(v *float64) string {
	if v == nil || *v == 0 {
		return "-"
	}
	return exact(*v)
}

// slots caps concurrent `models` calls: each one downloads from its CDN, and
// 32 at once made 87 of 697 fail with "Failed to fetch benchmark data".
var slots = make(chan struct{}, 4)
