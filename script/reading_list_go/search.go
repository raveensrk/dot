package main

// Finding every reading_list.yaml under ~.
//
// The walk follows symlinked folders, so ~/iCloud (a link into
// ~/Library/Mobile Documents/com~apple~CloudDocs) is searched even though
// ~/Library itself is skipped. A folder or file reached twice, through a link
// and through its real path, counts once; that also stops link loops. Broken
// links and unreadable folders are skipped without a word.
//
// Measured 2026-10-11: ~/Library alone took a whole-home search from 0.6 s to
// 78.1 s; iCloud Drive (15,945 files) walks in 0.06 s. The found paths are
// remembered, so a normal call reads one small file instead of walking.

import (
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

// buildDirs are dependency and build output folders: never a reading list,
// often huge.
var buildDirs = map[string]bool{
	"node_modules": true, "target": true, "dist": true, "build": true,
	"vendor": true, "__pycache__": true, "venv": true,
}

// cacheMaxAge is how long remembered paths are trusted before a fresh walk.
const cacheMaxAge = 24 * time.Hour

// refresh forces a fresh walk; `files` sets it.
var refresh bool

func cachePath(home string) string {
	return filepath.Join(home, ".cache", "dot_bin", "reading_list_paths")
}

// listPaths is every reading_list.yaml under HOME: the remembered paths when
// they are fresh and all still exist, else a new walk, which is remembered.
func listPaths(home string) []string {
	if !refresh {
		if paths, ok := remembered(home); ok {
			return paths
		}
	}
	paths := walk(home)
	forget := cachePath(home)
	if os.MkdirAll(filepath.Dir(forget), 0o755) == nil {
		os.WriteFile(forget, []byte(strings.Join(paths, "\n")+"\n"), 0o644)
	}
	return paths
}

// remembered reads the cache; ok is false when it is missing, older than
// cacheMaxAge, or names a file that is gone.
func remembered(home string) ([]string, bool) {
	file := cachePath(home)
	info, err := os.Stat(file)
	if err != nil || time.Since(info.ModTime()) > cacheMaxAge {
		return nil, false
	}
	data, err := os.ReadFile(file)
	if err != nil {
		return nil, false
	}
	var paths []string
	for _, p := range strings.Split(strings.TrimSpace(string(data)), "\n") {
		if p == "" {
			continue
		}
		if _, err := os.Stat(p); err != nil {
			return nil, false
		}
		paths = append(paths, p)
	}
	return paths, true
}

// forgetPaths drops the cache, so the next call walks: after add creates a
// new reading_list.yaml.
func forgetPaths(home string) {
	os.Remove(cachePath(home))
}

// walk searches HOME. When one real file is reached by several paths, the
// shortest path is kept (~/iCloud/x over ~/Library/Mobile Documents/...).
func walk(home string) []string {
	found := map[string]string{} // real path -> shortest path seen
	seen := map[string]bool{}    // real folders already walked
	var visit func(dir string)
	visit = func(dir string) {
		real, err := filepath.EvalSymlinks(dir)
		if err != nil || seen[real] {
			return
		}
		seen[real] = true
		entries, err := os.ReadDir(dir)
		if err != nil {
			return
		}
		for _, e := range entries {
			name := e.Name()
			path := filepath.Join(dir, name)
			// os.Stat follows a link; a broken one fails and is skipped.
			info, err := os.Stat(path)
			if err != nil {
				continue
			}
			if info.IsDir() {
				if strings.HasPrefix(name, ".") || buildDirs[name] {
					continue
				}
				if dir == home && name == "Library" {
					continue
				}
				visit(path)
				continue
			}
			if name != fileName {
				continue
			}
			realFile, err := filepath.EvalSymlinks(path)
			if err != nil {
				continue
			}
			if have, ok := found[realFile]; !ok || len(path) < len(have) {
				found[realFile] = path
			}
		}
	}
	visit(home)
	paths := make([]string, 0, len(found))
	for _, p := range found {
		paths = append(paths, p)
	}
	sort.Strings(paths)
	return paths
}
