// ai-model-bench-report - one report of AI model benchmarks from two CLIs:
//
//	cloud  `models benchmarks` (Artificial Analysis data via models.dev):
//	       top models by intelligence index, with coding index, price, speed
//	local  `llmfit recommend`: the models that fit this machine's hardware,
//	       ranked by llmfit's fit/speed/quality score
//
// Build and install: ~/dot/install.sh --apply, or by hand
//
//	cd ~/dot/script/ai_model_bench_report_go && go build -o ~/.local/bin/ai-model-bench-report .
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"sync"
	"text/tabwriter"
)

const usage = `ai-model-bench-report - AI model benchmarks from the models and llmfit CLIs

Usage:
  ai-model-bench-report [-n N] [--json] [--cloud | --local]
  ai-model-bench-report show MODEL[:EFFORTS] ... [-e EFFORTS] [--hl ROWS] [--json]
  ai-model-bench-report -h | --help | help

Options:
  -n N      rows per section (default 15)
  --json    print one JSON object {cloud, system, local} instead of tables
  --cloud   only the cloud section (models benchmarks)
  --local   only the local section (llmfit recommend)

show: compare any models at any effort levels, one column per model + effort
  MODEL       name or slug; case, spaces, dots and dashes are ignored:
              "gpt 5.6 sol" = gpt-5.6-sol = gpt-5-6-sol
  :EFFORTS    efforts for that model only, comma separated: max, xhigh, high,
              medium, low, minimal, reasoning, non-reasoning, default (no
              effort tag); none = every effort
  -e EFFORTS  efforts for the models given without a colon
  --hl ROWS   rows to highlight, comma separated, matched loosely by label or
              key (default "intelligence index,output tok/s,ttft s";
              AI_BENCH_HIGHLIGHT overrides it, --hl "" turns it off).
              Color only on a terminal; NO_COLOR turns it off
  --json      the full models benchmarks show entries

Examples:
  ai-model-bench-report
  ai-model-bench-report -n 5 --local
  ai-model-bench-report --json | jq '.cloud[0]'
  ai-model-bench-report show "opus 5.5"
  ai-model-bench-report show gpt-5.6-sol -e high,low
  ai-model-bench-report show gpt-6.1-sol:max,low "opus 5.5:high" sonnet-5.5:max
  ai-model-bench-report show "opus 5.5" --hl intel,hle,price_blended

Needs: brew install models llmfit
Exit codes: 0 success; 1 a CLI failed or is missing; 2 bad arguments.
`

// Bench is one `models benchmarks show --json` entry; pointers are null-able scores.
type Bench struct {
	Slug   string   `json:"slug"`
	Name   string   `json:"display_name"`
	Tag    *string  `json:"variant_tag"`
	Maker  string   `json:"creator_name"`
	Date   string   `json:"release_date"`
	Open   bool     `json:"open_weights"`
	Intel  *float64 `json:"intelligence_index"`
	Coding *float64 `json:"coding_index"`
	Input  *float64 `json:"price_input"`
	Output *float64 `json:"price_output"`
	TPS    *float64 `json:"output_tps"`
	TTFT   *float64 `json:"ttft"`
}

// Fit is one model from `llmfit recommend`.
type Fit struct {
	Name    string  `json:"name"`
	Params  string  `json:"parameter_count"`
	Fit     string  `json:"fit_level"`
	Quant   string  `json:"best_quant"`
	Runtime string  `json:"runtime"`
	Score   float64 `json:"score"`
	TPS     float64 `json:"estimated_tps"`
	Memory  float64 `json:"memory_required_gb"`
	Use     string  `json:"use_case"`
}

// System is the hardware llmfit detected.
type System struct {
	CPU  string  `json:"cpu_name"`
	GPU  string  `json:"gpu_name"`
	RAM  float64 `json:"total_ram_gb"`
	VRAM float64 `json:"gpu_vram_gb"`
	Back string  `json:"backend"`
}

type Report struct {
	Cloud  []Bench `json:"cloud,omitempty"`
	System *System `json:"system,omitempty"`
	Local  []Fit   `json:"local,omitempty"`
}

func main() {
	if len(os.Args) > 1 && os.Args[1] == "help" {
		fmt.Print(usage)
		return
	}
	if len(os.Args) > 1 && os.Args[1] == "show" {
		show(os.Args[2:])
		return
	}
	flag.Usage = func() { fmt.Fprint(os.Stderr, usage) }
	rows := flag.Int("n", 15, "rows per section")
	asJSON := flag.Bool("json", false, "JSON output")
	cloud := flag.Bool("cloud", false, "only cloud")
	local := flag.Bool("local", false, "only local")
	flag.Parse()
	if *rows < 1 || (*cloud && *local) || flag.NArg() > 0 {
		flag.Usage()
		os.Exit(2)
	}

	var report Report
	if !*local {
		report.Cloud = benches(*rows)
	}
	if !*cloud {
		report.System, report.Local = fits(*rows)
	}

	if *asJSON {
		out := json.NewEncoder(os.Stdout)
		out.SetIndent("", "  ")
		out.Encode(report)
		return
	}
	print(report)
}

// run executes a CLI and returns stdout, exiting 1 with its stderr on failure.
func run(name string, args ...string) []byte {
	out, err := exec.Command(name, args...).Output()
	if err == nil {
		return out
	}
	msg := err.Error()
	if exit, ok := err.(*exec.ExitError); ok {
		msg = strings.TrimSpace(string(exit.Stderr))
	}
	fmt.Fprintf(os.Stderr, "error: %s %s: %s (install: brew install models llmfit)\n",
		name, strings.Join(args, " "), msg)
	os.Exit(1)
	return nil
}

// benches takes the top N slugs by intelligence, then fetches each entry's full
// scores in parallel: `list` returns only the sort column, `show` has them all.
func benches(rows int) []Bench {
	var top []Bench
	list := run("models", "benchmarks", "list", "--sort", "intelligence",
		"--limit", fmt.Sprint(rows), "--json")
	if err := json.Unmarshal(list, &top); err != nil {
		fmt.Fprintln(os.Stderr, "error: parse models benchmarks list:", err)
		os.Exit(1)
	}

	var wg sync.WaitGroup
	for i := range top {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			fetch(top[i].Slug, &top[i])
		}(i)
	}
	wg.Wait()
	return top
}

// fits returns llmfit's detected hardware and its top N recommendations.
func fits(rows int) (*System, []Fit) {
	var out struct {
		System System `json:"system"`
		Models []Fit  `json:"models"`
	}
	if err := json.Unmarshal(run("llmfit", "recommend", "-n", fmt.Sprint(rows)), &out); err != nil {
		fmt.Fprintln(os.Stderr, "error: parse llmfit recommend:", err)
		os.Exit(1)
	}
	return &out.System, out.Models
}

// num formats a nullable score exactly, never rounded; "-" when the source
// has no value.
func num(v *float64) string {
	if v == nil {
		return "-"
	}
	return exact(*v)
}

func print(r Report) {
	tab := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', tabwriter.AlignRight)

	if r.Cloud != nil {
		fmt.Println("== Cloud models by intelligence (models benchmarks, Artificial Analysis)")
		fmt.Fprintln(tab, "#\tModel\tMaker\tReleased\tWeights\tIntel\tCoding\t$In/1M\t$Out/1M\tTok/s\tTTFT s\t")
		for i, b := range r.Cloud {
			name := b.Name // e.g. "Claude Opus 5.5 (Max)": one row per effort variant
			if b.Tag != nil && *b.Tag != "" {
				name += " (" + *b.Tag + ")"
			}
			weights := "closed"
			if b.Open {
				weights = "open"
			}
			fmt.Fprintf(tab, "%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n", i+1, name, b.Maker,
				b.Date, weights, num(b.Intel), num(b.Coding),
				price(b.Input), price(b.Output), num(b.TPS), num(b.TTFT))
		}
		tab.Flush()
	}

	if r.System != nil {
		if r.Cloud != nil {
			fmt.Println()
		}
		s := r.System
		fmt.Printf("== Local models that fit this machine (llmfit recommend)\n%s, %s GB RAM, %s %s GB (%s)\n",
			s.CPU, exact(s.RAM), s.GPU, exact(s.VRAM), s.Back)
		fmt.Fprintln(tab, "#\tModel\tParams\tFit\tQuant\tRuntime\tScore\tTok/s\tMem GB\tUse\t")
		for i, f := range r.Local {
			fmt.Fprintf(tab, "%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n", i+1, f.Name, f.Params,
				f.Fit, f.Quant, f.Runtime, exact(f.Score), exact(f.TPS), exact(f.Memory), f.Use)
		}
		tab.Flush()
	}
}
