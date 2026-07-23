# Rails learning notes

Personal study notes on this codebase, kept on the `notes` branch. Not part of
TheOdinProject — see `docs/superpowers/specs/2026-07-23-rails-learning-docs-design.md`
for why this exists and how it is meant to work.

## The documents

| File | What it is for |
|---|---|
| [`learning-plan.md`](learning-plan.md) | The spine. 15 stages, each with gate questions, anchors, and exit criteria. Start here. |
| [`progress.md`](progress.md) | Confidence per topic and when to resurface it. This is the scheduling data — without it there is no spacing. |
| [`concepts/`](concepts/) | One file per concept, in my own words. Written when a gate fails or something clicks. |
| [`questions.md`](questions.md) | Open questions caught mid-session so they neither get lost nor derail the stage in progress. |
| [`interview-prep.md`](interview-prep.md) | Technical retrieval under pressure: tradeoff talking points, drills, honest weak spots. |
| [`job-search.md`](job-search.md) | The non-technical half of getting hired. Not gated by any stage — start early. |
| [`reference-repos.md`](reference-repos.md) | The hand-picked second-exposure repos and how to query the wider corpus. |

## The workflow

1. Open the current stage in `learning-plan.md`.
2. **Answer the gate questions before opening any code.** A wrong written answer beats
   a skimmed correct one — the attempt is the learning; the pass/fail is a side
   benefit.
3. Read the anchors. Compare against what you wrote.
4. Where an answer was wrong or thin, write a `concepts/` file in your own words.
5. Record the confidence mark and date in `progress.md`.
6. Advance when every gate in the stage is at `✓` or better — not when the estimated
   hours are spent.

## Confidence marks

| Mark | Meaning | Action |
|---|---|---|
| `—` | Not started | — |
| `~` | Attempted, shaky | Resurface after ~3 weeks |
| `✓` | Gate passed | Re-test at second exposure |
| `✓✓` | Re-passed after a gap | Durable; stop revisiting |

An all-`✓` board means the gates are too easy. `~` marks are a sign the system is
working.

## Citing code

Every note must cite the code it is about, and **quote the line as well as cite it** —
line numbers rot as both codebases move; the path plus the quoted snippet is the
durable part.

- This repo: `` `app/models/user.rb:23` ``
- A picked repo: `` `rwr:chatwoot app/models/account.rb:40` ``

Where the quote is a fenced code block directly under the citation, put it in that
shape — the checker verifies those automatically:

    **Where it shows up** — `app/models/user.rb:23`:

    ```ruby
    belongs_to :path, optional: true, counter_cache: true
    ```

Check every citation:

```bash
ruby docs/bin/verify_citations.rb
```

Exits 0 when clean. It checks three things: the file exists, the line is in range,
and — for a fenced block sitting directly under a citation — that the quoted text
still matches that line. It also reports anything *shaped* like a citation that it
cannot parse, so a typo fails loudly instead of passing unnoticed.

Quotes written inline in prose are **not** machine-checked; they are too fuzzy to match
reliably. Those stay your responsibility.

Run it after a rebase onto upstream — that is when line numbers move. Process
documents under `docs/superpowers/` are skipped by default, since they discuss
citations rather than depend on them; pass one as an argument to check it anyway.

## Branch rules

- All learning work happens on `notes`. Never on `main`.
- Contributions to upstream TheOdinProject branch from `main`, never from `notes`.
- Commit messages follow this repo's convention: `Chore:` / `Feature:` / `Fix:`.
- Stay current with `git fetch upstream && git rebase upstream/main`. `docs/` does not
  exist upstream, so this stays conflict-free. If upstream ever adds its own `docs/`,
  rename this tree to `_learning/` — a one-commit change.
