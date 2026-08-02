# TODO

## Parallel repo sync in `script/,sync.py`

Current workflow is too slow — there is a lot of waiting time.

- Run the repo sync in parallel instead of sequentially.
- When a dirty repo is found, do **not** take any action on it. Just mark it dirty.
- At the end, print successfully synced repos first, then the dirty repos.
- Then prompt with a yes/no question for each dirty repo asking whether to handle
  it with `lazygit`.

**Note:** brainstorm this workflow before implementing it.
