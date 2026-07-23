# Rails Learning Docs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the eight-document learning system specified in
`docs/superpowers/specs/2026-07-23-rails-learning-docs-design.md`, with stages 0–2
authored in full against verified anchors in this codebase.

**Architecture:** Plain Markdown under `docs/` on the `notes` branch. The spine is
`learning-plan.md` (15 stages + a parallel CS track); `progress.md` holds the
scheduling data; the rest are capture and hiring documents. Because the deliverable is
prose rather than code, the TDD cycle is replaced by an executable **citation
verifier** (`docs/bin/verify_citations.rb`) written in Task 1 — every subsequent task
writes content, runs the verifier, and commits only on green.

**Tech Stack:** Markdown, Ruby 3.4 (verifier script only), git.

## Global Constraints

Copied verbatim from the spec. Every task's requirements implicitly include these.

- **Branch:** all learning work happens on `notes`. Never commit these files to `main`.
  Verify with `git branch --show-current` before every commit step.
- **Commit convention:** `Chore: …` / `Feature: …` / `Fix: …` — the repo's existing
  convention (see `git log --oneline`). Use `Chore:` for every commit in this plan.
- **Citation convention (mandatory on every note):**
  - This repo: `` `app/models/user.rb:23` ``
  - A picked repo: `` `rwr:chatwoot app/models/account.rb:40` ``
  - "A note without a citation is considered unfinished."
- **Citations must quote the line, not only cite it** (spec §9) — line numbers rot;
  the path plus quoted snippet is the durable part.
- **Confidence scale** (spec §5.5), used verbatim wherever marks appear:
  `—` not started · `~` attempted, shaky (resurface after ~3 weeks) · `✓` gate passed
  (re-test at second exposure) · `✓✓` re-passed after a gap (durable; stop revisiting).
- **Advancement is gated, not scheduled:** stage *n+1* opens when stage *n*'s gates are
  at `✓` or better, regardless of elapsed time. The CS track (§6.2) is exempt.
- **Gate questions must be:** specific enough to fail cleanly; answerable in 2–5
  minutes; anchored to a named file to read immediately afterwards. 4–8 per stage.
- **Decoupled from the starter kit.** No stage may reference a
  `~/projects/starter-kit/rails-template` phase as a prerequisite. Mentioning the kit
  as a place code practice happens is permitted (spec §3, §5.6); creating a dependency
  is not.
- **Estimates carry ±30%** wherever printed.
- **Stages 3–14 are headings plus scope only** — spec §7.2: "Stages are written on
  demand, not upfront." Authoring their gate questions now is a plan violation, not a
  bonus.
- **Learner pitch is review, not first-time teaching.** Ruby/Rails basics were learned
  ~late 2024 (Hartl); the learner has 20+ shipped Ember.js projects. Never explain
  syntax from zero. Ember contrasts are an encouraged teaching device.

---

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `docs/bin/verify_citations.rb` | Executable check that every citation resolves | 1 |
| `docs/README.md` | Signpost: what each file is for, workflow, conventions, branch rules | 2 |
| `docs/learning-plan.md` | The spine — 15 stages + CS track; stages 0–2 in full | 3–6 |
| `docs/progress.md` | Confidence table + session log; the scheduling data | 7 |
| `docs/concepts/README.md` | How concept files are written | 8 |
| `docs/concepts/counter-cache.md` | The worked example concept file | 8 |
| `docs/questions.md` | Open / Answered question queues | 8 |
| `docs/interview-prep.md` | Technical: tradeoffs, drills, weak spots | 9 |
| `docs/job-search.md` | Non-technical hiring process + freelance | 9 |
| `docs/reference-repos.md` | The 3 picks and the on-demand corpus | 10 |

`learning-plan.md` is split across four tasks because it is the only file where a
reviewer could sensibly approve the skeleton and reject a stage's gate questions.

---

### Task 1: Citation verifier

The test harness for the whole plan. Written first so every later task has something
to run.

**Files:**
- Create: `docs/bin/verify_citations.rb`

**Interfaces:**
- Consumes: nothing.
- Produces: `ruby docs/bin/verify_citations.rb` — exits `0` when every citation in
  `docs/**/*.md` resolves, exits `1` and prints each failure otherwise. Recognised
  citation forms: `` `app/models/user.rb:23` `` (this repo) and
  `` `rwr:chatwoot app/models/account.rb:40` `` (a repo under
  `~/projects/rails-study/real-world-rails/apps/`). Every later task runs this command
  as its verification step.

  **As-built, after review** (the steps below are the first cut; three findings and one
  added requirement changed the contract, and later tasks depend on the final one):
  - **Two-stage detection.** A loose pass finds anything *shaped* like a citation; a
    strict pass validates it. Loose-but-not-strict is a reported failure, so a
    malformed citation fails loudly instead of being silently unmatched. The original
    single regex made a typo'd citation invisible — `checked 0 citation(s) … OK`.
  - **No path-prefix allowlist.** Any path shape is accepted; existence settles it.
    The original `app|lib|db|spec|config|bin` list silently dropped `test/` citations
    into Minitest-based picked repos.
  - **Bad CLI arguments** produce a reported failure, not a Ruby backtrace.
  - **Scoped quote checking.** When a fenced code block sits directly under a citation,
    the block's first non-empty line must match the cited line (compared stripped).
    Inline prose quotes are deliberately not checked — too fuzzy to match reliably.
  - **`docs/superpowers/` is excluded from the default glob**, since the spec and this
    plan discuss citations rather than depend on them and deliberately contain broken
    examples. An explicit path argument still checks them.

- [ ] **Step 1: Write the failing test — a scratch doc with one good and two bad citations**

```bash
mkdir -p docs/bin
cat > /tmp/verify_fixture.md <<'EOF'
Good: `app/models/user.rb:23`
Bad path: `app/models/nonexistent_thing.rb:5`
Bad line: `app/models/user.rb:99999`
EOF
```

- [ ] **Step 2: Run the verifier to confirm it does not exist yet**

Run: `ruby docs/bin/verify_citations.rb`
Expected: FAIL — `ruby: No such file or directory -- docs/bin/verify_citations.rb`

- [ ] **Step 3: Write the verifier**

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Verifies that every code citation in docs/ resolves to a real file and a real line.
#
# Citation forms (see docs/README.md):
#   `app/models/user.rb:23`                     -> this repo
#   `rwr:chatwoot app/models/account.rb:40`     -> a repo in real-world-rails
#
# Usage: ruby docs/bin/verify_citations.rb [path ...]
#        exits 0 when all citations resolve, 1 otherwise.

REPO_ROOT = File.expand_path('../..', __dir__)
RWR_ROOT  = File.expand_path('~/projects/rails-study/real-world-rails/apps')

CITATION = %r{
  `                                        # opening backtick
  (?:rwr:(?<app>[a-z0-9_.-]+)\s+)?         # optional picked-repo prefix
  (?<path>(?:app|lib|db|spec|config|bin)/[\w./-]+\.(?:rb|sql|erb|yml|yaml|js|json))
  :(?<line>\d+)                            # line number
  `                                        # closing backtick
}x

targets = ARGV.empty? ? Dir.glob(File.join(REPO_ROOT, 'docs', '**', '*.md')) : ARGV
failures = []
checked = 0

targets.sort.each do |doc|
  File.readlines(doc).each_with_index do |text, idx|
    text.scan(CITATION) do
      m = Regexp.last_match
      checked += 1
      where = "#{doc.sub("#{REPO_ROOT}/", '')}:#{idx + 1}"

      if m[:app] && !Dir.exist?(File.join(RWR_ROOT, m[:app]))
        failures << "#{where}  unknown picked repo: rwr:#{m[:app]}"
        next
      end

      base = m[:app] ? File.join(RWR_ROOT, m[:app]) : REPO_ROOT
      full = File.join(base, m[:path])

      unless File.file?(full)
        failures << "#{where}  missing file: #{m[:app] ? "rwr:#{m[:app]} " : ''}#{m[:path]}"
        next
      end

      total = File.foreach(full).count
      if m[:line].to_i > total
        failures << "#{where}  #{m[:path]}:#{m[:line]} out of range (file has #{total} lines)"
      end
    end
  end
end

puts "checked #{checked} citation(s) across #{targets.size} file(s)"

if failures.empty?
  puts 'OK'
  exit 0
end

warn "\n#{failures.size} bad citation(s):"
failures.each { |f| warn "  #{f}" }
exit 1
```

- [ ] **Step 4: Run the verifier against the fixture to prove it catches both failures**

Run: `ruby docs/bin/verify_citations.rb /tmp/verify_fixture.md`
Expected: exit 1, output containing
```
checked 3 citation(s) across 1 file(s)

2 bad citation(s):
  /tmp/verify_fixture.md:2  missing file: app/models/nonexistent_thing.rb
  /tmp/verify_fixture.md:3  app/models/user.rb:99999 out of range (file has 87 lines)
```

- [ ] **Step 5: Run it against the good citation alone to prove it passes**

```bash
echo 'Good: `app/models/user.rb:23`' > /tmp/verify_ok.md
ruby docs/bin/verify_citations.rb /tmp/verify_ok.md
```
Expected: exit 0, `checked 1 citation(s) across 1 file(s)` then `OK`

- [ ] **Step 6: Make it executable and clean up fixtures**

```bash
chmod +x docs/bin/verify_citations.rb
rm /tmp/verify_fixture.md /tmp/verify_ok.md
```

- [ ] **Step 7: Commit**

```bash
git branch --show-current   # must print: notes
git add docs/bin/verify_citations.rb
git commit -m "Chore: add citation verifier for learning docs"
```

---

### Task 2: `docs/README.md`

**Files:**
- Create: `docs/README.md`

**Interfaces:**
- Consumes: `ruby docs/bin/verify_citations.rb` from Task 1.
- Produces: the canonical statement of the citation convention and the confidence
  scale. Later documents link here rather than restating the rules.

- [ ] **Step 1: Write the file**

```markdown
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
```

- [ ] **Step 2: Verify citations resolve**

Run: `ruby docs/bin/verify_citations.rb`
Expected: exit 0. Note the inline examples are inside double-backtick spans, so the
regex sees `` `app/models/user.rb:23` `` and checks it — `app/models/user.rb` has 87
lines, so line 23 is valid and this passes.

- [ ] **Step 3: Verify every internal link points at a file this plan creates**

```bash
grep -o '](\([a-z/.-]*\))' docs/README.md
```
Expected: `learning-plan.md`, `progress.md`, `concepts/`, `questions.md`,
`interview-prep.md`, `job-search.md`, `reference-repos.md`. All are created by later
tasks in this plan; none is a typo or an invented file.

- [ ] **Step 4: Commit**

```bash
git branch --show-current   # must print: notes
git add docs/README.md
git commit -m "Chore: add learning docs README"
```

---

### Task 3: `learning-plan.md` skeleton

All 15 stages plus the CS track as headings with goal, scope, and estimate. Stages 0–2
get placeholder gate sections filled in by Tasks 4–6.

**Files:**
- Create: `docs/learning-plan.md`

**Interfaces:**
- Consumes: `docs/README.md` (linked back to for conventions).
- Produces: the per-stage heading format `## Stage N — Title` and the six-part stage
  body (**Goal** / **Gate questions** / **Anchors** / **Second exposure** /
  **Estimate** / **Exit criteria**). Tasks 4–6 fill the gate sections in place; Task 7
  reads the stage titles to seed `progress.md`.

- [ ] **Step 1: Write the header and the stage index**

```markdown
# Learning plan

Dependency-ordered. Each stage depends only on earlier ones. **≈ 1,060 h total**
(990 h main track + 70 h CS track), every estimate ±30%.

Estimates are elastic and deliberately not converted into dates. Advancement is gated
by confidence, not by elapsed time — see [`README.md`](README.md#confidence-marks).

**Answer the gate questions before opening the anchors.** That is the whole
mechanism; skipping it turns this into a reading list.

## Stages

| # | Stage | Est. h | Status |
|---|---|---|---|
| 0 | [Ruby fluency](#stage-0--ruby-fluency) | 70 | authored |
| 1 | [The database](#stage-1--the-database) | 90 | authored |
| 2 | [ActiveRecord depth](#stage-2--activerecord-depth) | 80 | authored |
| 3 | [Request layer](#stage-3--request-layer) | 45 | scope only |
| 4 | [Testing / RSpec](#stage-4--testing--rspec) | 90 | scope only |
| 5 | [App architecture](#stage-5--app-architecture) | 70 | scope only |
| 6 | [Auth & authorization](#stage-6--auth--authorization) | 70 | scope only |
| 7 | [Frontend in Rails](#stage-7--frontend-in-rails) | 50 | scope only |
| 8 | [Async](#stage-8--async) | 55 | scope only |
| 9 | [Performance](#stage-9--performance) | 70 | scope only |
| 10 | [APIs](#stage-10--apis) | 65 | scope only |
| 11 | [Payments & commerce](#stage-11--payments--commerce) | 70 | scope only |
| 12 | [Security](#stage-12--security) | 45 | scope only |
| 13 | [Ops & deploy](#stage-13--ops--deploy) | 60 | scope only |
| 14 | [Real-codebase work](#stage-14--real-codebase-work) | 60 | scope only |
| — | [CS fundamentals (parallel)](#cs-fundamentals--parallel-track) | 70 | scope only |

Stages 3–14 are **written on demand**: stage *n+1* is authored as stage *n* nears
completion, so its gate questions reflect what has actually proven weak rather than
what seemed likely at the outset. Until then they carry scope and estimate only.

Cross-cutting topics are folded in where they arise rather than given their own
stages: ActiveStorage, ActionMailer, i18n, ActiveSupport, Git/PR workflow.

**Ordering rationale.** Stage 1 precedes 2 because ActiveRecord without SQL produces
working code over a badly modeled schema — the characteristic failure of frontend
developers moving to backend. Stage 4 is early despite being new material so every
later stage can be practised through tests. Stage 7 is cheap because Ember experience
transfers almost directly.

## Working alongside TOP's own curriculum

This plan runs in parallel with **TOP's Full Stack Ruby on Rails path**, and the split
is asymmetric: TOP is breadth-first and project-driven; this plan is depth-first and
codebase-driven. Where TOP covers a stage, use **TOP's lessons and projects as the
guided path** and use these gates only to verify retention. Do not re-derive material
TOP already sequences well.

Per-stage TOP coverage is noted in each stage's **TOP** line below. In summary: TOP
substantially covers stages 0, 2, 3, 7 and partly 4, 6, 10. This plan's irreducible
value is stages **1, 5, 8, 9, 11, 12, 13, 14**.

Also worth taking from TOP outside this structure: **Ruby → Intermediate Git**.
**Skip** TOP's Intermediate/Advanced HTML and CSS, JavaScript, and React courses —
already covered by 20+ shipped Ember projects.

## Where the code writing happens

Deliberately not here. Two outlets already exist:

- **TOP's own curriculum projects** — Micro-Reddit, Private Events, Flight Booker,
  Members Only!, Kittens API, Pexels API, Odin Book, Connect Four, Chess.
- **The starter kit** (`~/projects/starter-kit/rails-template`), which has its own
  roadmap and is scheduled independently of this plan.

No stage here waits on a kit phase and no kit phase waits on a stage. The risk of this
split is that gates keep passing while real ability stalls — which is why
[`progress.md`](progress.md) tracks when code was last written.

---
```

- [ ] **Step 2: Write stages 0–2 as skeletons with a placeholder gate marker**

Append. Tasks 4–6 replace each `<!-- GATES: filled by Task N -->` line in place.

```markdown
## Stage 0 — Ruby fluency

**Goal:** Read any Ruby method in an unfamiliar Rails app and know what it does
without guessing — including what `self` is, where a method came from, and whether a
block will behave like a closure.

**Scope:** blocks/procs/lambdas/`yield`, modules & mixins, `include`/`extend`/`prepend`,
method lookup & `self`, Enumerable, exceptions, light metaprogramming (`define_method`,
`send`, `method_missing`), Ruby 3 idiom (keyword args, safe navigation, pattern
matching).

**TOP:** Use TOP's Ruby course → *Advanced Ruby* (Blocks, Pattern Matching, Custom
Enumerables) and *OOP Basics* as the guided path. **Skip *Basic Ruby*** — below level
after Hartl.

**Estimate:** 70 h (±30%)

<!-- GATES: filled by Task 4 -->

---

## Stage 1 — The database

**Goal:** Design a schema and reason about what the database will actually do with a
query — before writing the ActiveRecord that produces it.

**Scope:** relational modeling, SQL joins/aggregates/subqueries/`GROUP BY`, indexes
(B-tree, composite, partial), `EXPLAIN` & query plans, transactions & isolation &
locking, constraints (FK/unique/check/NOT NULL), migrations, reversibility, backfills,
zero-downtime.

**TOP:** **Badly insufficient** — the entire Databases course is three lessons
(*Databases*, *Databases and SQL*, *SQL Zoo*) with no indexes, `EXPLAIN`,
transactions, locking, or constraints. Take SQL Zoo as a starting point; this stage's
90 h carries the rest.

**Estimate:** 90 h (±30%)

<!-- GATES: filled by Task 5 -->

---

## Stage 2 — ActiveRecord depth

**Goal:** Know which of ActiveRecord's many ways to express a query is the right one
here, and be able to say what SQL each will emit.

**Scope:** association options in full, scope composition & `merge`,
`includes`/`preload`/`eager_load`/`joins` and when each, callbacks and why to avoid
them, validations & custom validators, STI vs polymorphic vs delegated types,
`counter_cache`, `touch`, optimistic locking, query objects, Arel basics.

**TOP:** Use TOP's Rails course → *Active Record Basics* and *Advanced Forms and
Active Record* (Queries, Associations, Callbacks) as the guided path, with the
Micro-Reddit, Private Events, and Flight Booker projects. This stage adds
`includes`/`preload`/`eager_load`, STI vs delegated types, optimistic locking, and
Arel.

**Estimate:** 80 h (±30%)

<!-- GATES: filled by Task 6 -->

---
```

- [ ] **Step 3: Write stages 3–14 as scope-only sections**

Append. These carry **no gate questions** — authoring them now is a spec violation
(§7.2, "written on demand, not upfront").

```markdown
## Stage 3 — Request layer

**Scope:** Rack & the middleware stack, routing depth (constraints, nesting, concerns,
defaults), filters, strong params, sessions & cookies & CSRF, status codes &
redirects, caching headers, content negotiation.

**TOP:** Use TOP's *Rails Basics* (Routing, Controllers, Views, Store App). This stage
adds Rack/middleware depth.

**Estimate:** 45 h (±30%) · **Gates:** authored when stage 2 nears completion.

---

## Stage 4 — Testing / RSpec

**Scope:** `describe`/`context`/`it`, matchers, model & request & system specs,
FactoryBot, shoulda-matchers, stubs & mocks, VCR/WebMock for external APIs, Capybara +
cuprite, what to test, coverage vs confidence, TDD workflow.

**TOP:** *Testing Ruby with RSpec* (TDD, Intro to RSpec, Connect Four) — **partial**,
plain Ruby only. Rails-specific request and system specs, FactoryBot, VCR, and cuprite
are this stage's work. This repo has 228 spec files to read.

**Estimate:** 90 h (±30%) · **Gates:** authored when stage 3 nears completion.

---

## Stage 5 — App architecture

**Scope:** model & controller concerns, service objects/POROs, form objects, query
objects, presenters/decorators, ViewComponent, value objects, and the judgment of
which to reach for.

**TOP:** **Nothing.** Entirely this stage.

**Estimate:** 70 h (±30%) · **Gates:** authored when stage 4 nears completion.

---

## Stage 6 — Auth & authorization

**Scope:** Devise mapped onto existing hand-rolled knowledge, OmniAuth/OAuth2 flows,
2FA, sessions vs tokens, Pundit/CanCanCan/custom RBAC, **[multi-tenancy scoping]**.

**TOP:** *Forms and Authentication* (Sessions, Cookies and Authentication; Members
Only!) — **authentication only, hand-rolled**. No Devise, no OmniAuth, no
authorization at all.

**Second exposure:** chatwoot, for account-scoped multi-tenancy — the bracketed gap.

**Estimate:** 70 h (±30%) · **Gates:** authored when stage 5 nears completion.

---

## Stage 7 — Frontend in Rails

**Scope:** Turbo Drive/Frames/Streams, Stimulus, Propshaft, importmap, js/cssbundling,
ViewComponent + Lookbook, when real JS is warranted.

**TOP:** Use TOP's *Assets and Navigation* + *Rails Sprinkles*. Good coverage.

**Estimate:** 50 h (±30%) · **Gates:** authored when stage 6 nears completion.
Expected to be the cheapest stage — Ember experience transfers almost directly.

---

## Stage 8 — Async

**Scope:** ActiveJob abstraction, Sidekiq vs Solid Queue, idempotency, retries &
backoff, dead-letter handling, cron/scheduled jobs, ActionCable & Turbo Stream
broadcasting.

**TOP:** *Websockets and ActionCable* only — **partial**. No job queues, idempotency,
or retries.

**Estimate:** 55 h (±30%) · **Gates:** authored when stage 7 nears completion.

---

## Stage 9 — Performance

**Scope:** rack-mini-profiler, stackprof, fragment & russian-doll caching, low-level &
HTTP caching, Solid Cache, Bullet, N+1 in practice, memory & GC basics.

**TOP:** **Nothing.**

**Estimate:** 70 h (±30%) · **Gates:** authored when stage 8 nears completion.

---

## Stage 10 — APIs

**Scope:** REST design, versioning, serializers (jbuilder/alba/AMS), token auth, rate
limiting, webhooks in both directions, GraphQL awareness — **[all of it]**.

**TOP:** *APIs* (Building Your Own, External APIs, Kittens API, Pexels API) — a decent
start. This stage adds versioning, serializers, token auth, rate limiting.

**Second exposure:** chatwoot, which has a real versioned API. This repo has
essentially no API surface, which is why the whole scope is bracketed.

**Estimate:** 65 h (±30%) · **Gates:** authored when stage 9 nears completion.

---

## Stage 11 — Payments & commerce

**Scope:** Stripe charges/subscriptions/webhooks/idempotency, the `pay` gem, money
modeling in integer cents & currency, invoicing, refunds, taxes, PCI awareness —
**[all of it]**.

**TOP:** **Nothing.**

**Second exposure:** gumroad — real payments, payouts, and money modeling in
production. Nothing in this repo touches money.

**Estimate:** 70 h (±30%) · **Gates:** authored when stage 10 nears completion.

---

## Stage 12 — Security

**Scope:** OWASP Top 10 in Rails terms, mass assignment, SQL injection, XSS in ERB,
CSRF, credentials & secrets, Brakeman, bundler-audit, rack-attack.

**TOP:** **Nothing.** This repo runs rack-attack in production, so the anchors exist.

**Estimate:** 45 h (±30%) · **Gates:** authored when stage 11 nears completion.

---

## Stage 13 — Ops & deploy

**Scope:** Docker, Kamal, env & credentials, zero-downtime migrations in production,
backups, Sentry & monitoring, log aggregation, CI/CD.

**TOP:** *Deployment* — one lesson. **Minimal.**

**Estimate:** 60 h (±30%) · **Gates:** authored when stage 12 nears completion.

---

## Stage 14 — Real-codebase work

**Scope:** reading unfamiliar code fast, Rails version upgrades, legacy patterns &
deprecations, debugging production issues, estimation & scoping.

**TOP:** **Nothing** — TOP is greenfield-only by design, which is exactly the gap.

**Second exposure:** lobsters, adopted here and not before. It is small enough to read
end-to-end, which is the only way to practise whole-codebase comprehension.

**Estimate:** 60 h (±30%) · **Gates:** authored when stage 13 nears completion.

---

## CS fundamentals — parallel track

**Scope:** a brief intro to CS, recursive methods & recursion, time complexity, space
complexity, common data structures & algorithms, linked lists, hashmaps, binary search
trees, Knight's Travails.

**Source:** TOP's Ruby course, section *A Bit of Computer Science* — already sequenced
and project-backed. Follow it directly.

**Estimate:** 70 h (±30%)

**Run in parallel, not at the end.** Placing this after stage 14 would put it roughly
two years out, which is useless: DS&A screens are common in remote hiring and are
needed *before* the Rails depth is finished. Schedule it as a recurring slice — say one
session in four — whenever job applications are active.

**Exempt from gating.** This track neither blocks nor depends on any Rails stage.
```

- [ ] **Step 4: Verify citations and anchor links**

```bash
ruby docs/bin/verify_citations.rb
grep -c '^## Stage' docs/learning-plan.md
```
Expected: verifier exits 0 (this file has no code citations yet — Tasks 4–6 add them).
`grep -c` prints `15`.

- [ ] **Step 5: Verify no gate questions leaked into stages 3–14**

```bash
awk '/^## Stage 3/,0' docs/learning-plan.md | grep -c 'Gate questions' || true
```
Expected: `0`. Stages 3–14 carry scope and estimate only, per spec §7.2.

- [ ] **Step 6: Commit**

```bash
git branch --show-current   # must print: notes
git add docs/learning-plan.md
git commit -m "Chore: add learning plan skeleton with all 15 stages"
```

---

### Task 4: Stage 0 gates — Ruby fluency

**Files:**
- Modify: `docs/learning-plan.md` — replace `<!-- GATES: filled by Task 4 -->`

**Interfaces:**
- Consumes: the stage skeleton from Task 3.
- Produces: the authored-stage body format that Tasks 5 and 6 repeat —
  **Gate questions** (numbered, each ending with an anchor), **Anchors**,
  **Second exposure**, **Exit criteria**.

**Verified constraint discovered during research:** this repo contains **no**
`define_method`, `method_missing`, `each_with_object`, `reduce`, or `inject` anywhere
in `app/`. Metaprogramming and heavy Enumerable therefore have no local anchor and are
routed to TOP's Ruby course instead. Do not invent a citation for them.

- [ ] **Step 1: Replace the placeholder with the authored gate section**

Replace the line `<!-- GATES: filled by Task 4 -->` with:

```markdown
### Gate questions

Answer in writing before opening any file.

1. **Blocks, procs, and lambdas.** What does `return` do inside a lambda versus inside
   a proc? What about `yield` inside a method that was called without a block? Then
   read `app/models/concerns/likeable.rb:4` — `included do` takes a block; which of the
   three is it, and what is `self` inside it?

2. **`included do` vs a plain module method.** `app/models/concerns/likeable.rb:2` says
   `extend ActiveSupport::Concern`, and lines 4–7 wrap `has_many` and `attribute` in
   `included do`. Why can't those two lines sit directly in the module body alongside
   `def liked_by?` on line 9? What is the receiver in each case?

3. **`include` vs `extend`.** `Likeable` is `include`d into models; `ActiveSupport::Concern`
   is `extend`ed into `Likeable`. State the rule in one sentence, then predict what
   `Likeable.singleton_class.ancestors` contains.

4. **Method lookup.** If a model both `include`s `Likeable` and defines its own
   `liked_by?`, which wins? Now: if `Likeable` were `prepend`ed instead, which wins?
   How would you check at runtime without editing either file?

5. **Default-block hashes.** `app/models/user.rb:45` is
   `@progress ||= Hash.new { |hash, c| hash[c] = CourseProgress.new(c, self) }`.
   When does that block run? How many times, for three lookups of the same key? What
   would break if the block were `{ |_hash, c| CourseProgress.new(c, self) }` — no
   assignment?

6. **`||=` and falsy memoization.** `app/services/course_progress.rb:24` memoizes with
   `@lesson_ids ||= course.lesson_ids`. Under what value of the memoized result does
   this idiom silently recompute every call? Which of the memoized methods in that
   file could legitimately hit that case?

7. **Keyword args and shorthand.** `app/models/concerns/likeable.rb:10` is
   `likes.exists?(user:)`. Write out what that shorthand expands to, and say which
   Ruby version introduced it. Then: why does `has_many :likes, as: :likeable` on
   line 5 use symbols rather than keyword arguments?

8. **Exceptions.** Ruby's `rescue` with no class named catches `StandardError`, not
   `Exception`. Why does that distinction matter, and what would you break by writing
   `rescue Exception`? Anchor: `app/controllers/application_controller.rb:10`,
   `rescue_from ActiveRecord::RecordNotFound, with: :not_found_error` — is `rescue_from`
   the same mechanism as `rescue`?

### Anchors

| File | Why |
|---|---|
| `app/models/concerns/likeable.rb:1` | 31 lines; covers `extend ActiveSupport::Concern`, `included do`, blocks, and instance methods in one readable unit. Read the whole file. |
| `app/models/user.rb:45` | `Hash.new` with a default block — a closure capturing `self` |
| `app/services/course_progress.rb:24` | `\|\|=` memoization, three times in one file |
| `app/models/project_submission.rb:5` | `before_update do` — a callback in block form; contrast with the symbol form at `app/models/user.rb:4` |
| `app/controllers/application_controller.rb:10` | `rescue_from` as a class-level analogue of `rescue` |

**Not anchorable here.** This repo contains no `define_method`, `method_missing`,
`each_with_object`, `reduce`, or `inject` in `app/` — a finding worth noticing in its
own right: a disciplined production Rails app barely metaprograms. For those
sub-topics use TOP's Ruby course → *Advanced Ruby* (Blocks, Custom Enumerables) and
the Rails source itself (`ActiveSupport::Concern` is ~150 lines and is the canonical
`define_method`/`included` example).

### Second exposure

None scheduled. Ruby idiom recurs constantly in every later stage, which is spacing
enough.

### Exit criteria

Gates 1–8 at `✓`, and you can read
`app/models/concerns/likeable.rb:1` aloud line by line explaining what each does and
what `self` is at that point.
```

- [ ] **Step 2: Verify every citation resolves**

Run: `ruby docs/bin/verify_citations.rb docs/learning-plan.md`
Expected: exit 0, `OK`.

- [ ] **Step 3: Verify the quoted snippets match the real lines**

```bash
sed -n '4p' app/models/concerns/likeable.rb
sed -n '45p' app/models/user.rb
sed -n '24p' app/services/course_progress.rb
sed -n '10p' app/controllers/application_controller.rb
```
Expected, in order:
```
  included do
    @progress ||= Hash.new { |hash, c| hash[c] = CourseProgress.new(c, self) }
    @lesson_ids ||= course.lesson_ids
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_error
```
If any line differs, fix the quote in the doc — the quote is the durable part, not the
number.

- [ ] **Step 4: Re-confirm the negative finding still holds**

```bash
grep -rEn 'define_method|method_missing|each_with_object|\.(reduce|inject)\(' app/ | wc -l
```
Expected: `0`. If it is non-zero, the "not anchorable here" paragraph is now wrong —
replace it with the real anchor.

- [ ] **Step 5: Commit**

```bash
git branch --show-current   # must print: notes
git add docs/learning-plan.md
git commit -m "Chore: author stage 0 gates (Ruby fluency)"
```

---

### Task 5: Stage 1 gates — The database

**Files:**
- Modify: `docs/learning-plan.md` — replace `<!-- GATES: filled by Task 5 -->`

**Interfaces:**
- Consumes: the stage body format established in Task 4.
- Produces: nothing new structurally.

- [ ] **Step 1: Replace the placeholder with the authored gate section**

Replace the line `<!-- GATES: filled by Task 5 -->` with:

```markdown
### Gate questions

Answer in writing before opening any file. `psql` open is fine for questions 6–7 —
running SQL is not the same as reading the answer.

1. **Unique index vs uniqueness validation.** `db/schema.rb:69` is
   `t.index ["email"], name: "index_admin_users_on_email", unique: true`, and
   `app/models/user.rb:10` separately validates `uniqueness: true` on email. Why both?
   Describe the exact race that the validation alone cannot prevent, and what the app
   sees when the index catches it.

2. **Composite index column order.** `db/schema.rb:33` and `db/schema.rb:34` index
   `["owner_id", "owner_type"]` **and** `["owner_type", "owner_id"]` — the same two
   columns in both orders, on the same table. Is one of them dead weight? Give the
   query shape each one serves, and say what a B-tree's leftmost-prefix rule has to do
   with it.

3. **Missing foreign keys.** `db/schema.rb` has 64 `t.index` lines but only 13
   `add_foreign_key` lines, across 44 models. Name three things that can go wrong in a
   table with no FK constraint, then give the two most common legitimate reasons a
   production team omits one. (Look at *which* tables have them before answering.)

4. **What a transaction actually guarantees.** `app/models/user.rb:74` opens
   `ActiveRecord::Base.transaction do` around a multi-row update; the same pattern is
   at `app/services/users/reset_progress.rb:13` as `user.transaction do`. State what
   is guaranteed if the block raises. Then state what is **not** guaranteed: at
   Postgres's default isolation level, can a concurrent transaction see a row this
   block already wrote? Can this block's own reads change between two statements?

5. **Materialized views.** `db/views/` holds three Scenic views, e.g.
   `db/views/user_sign_ups_day_stats_v01.sql:1`. What does a materialized view buy
   that an index on the same table cannot? What is the cost, and what has to happen on
   a schedule for it to stay useful? Why `_v01` in the filename?

6. **`counter_cache` on existing data.** `app/models/user.rb:23` is
   `belongs_to :path, optional: true, counter_cache: true`. What column must exist on
   which table, and what is its exact name? Now the real question: you add this to a
   table with 100k existing rows. What is the value of that column immediately
   afterwards, and what do you have to do about it? Write the backfill.

7. **Write the SQL, then explain it.** Without ActiveRecord, write SQL for: *users who
   have completed at least one lesson in a given course*. Then run `EXPLAIN ANALYZE` on
   it against the dev database. Which indexes did the planner use? Add
   `ORDER BY users.created_at DESC LIMIT 20` — does the plan change, and why?

8. **Zero-downtime migration.** You need to add a `NOT NULL` column with a default to
   `users` in production, and rename another column. Write the migration sequence — how
   many deploys, and in what order do code and schema change? What specifically goes
   wrong if you do the rename in one step?

### Anchors

| File | Why |
|---|---|
| `db/schema.rb:1` | 396 lines, 64 indexes, 13 FK constraints. Read it end to end once — it is small enough, and schema reading is the skill. |
| `db/schema.rb:33` | The both-orders composite index pair |
| `db/schema.rb:69` | A unique index backing a model validation |
| `app/models/user.rb:74` | `ActiveRecord::Base.transaction` around a multi-step change |
| `app/services/users/reset_progress.rb:13` | `user.transaction` — same mechanism, instance-level entry point |
| `db/views/user_sign_ups_day_stats_v01.sql:1` | Scenic materialized view; compare against the other two in `db/views/` |
| `app/models/user.rb:23` | `counter_cache: true` on a `belongs_to` |

**Outside this repo:** Postgres's own documentation on index types and isolation
levels is the source here — this stage is the one where Rails docs are actively
insufficient. TOP's Databases course is three lessons and does not cover any of the
above; SQL Zoo is worth doing for join fluency and nothing beyond it.

### Second exposure

**gumroad**, at stage 11. Money modeling forces constraint and precision questions
that a course platform never raises. Note the pairing when you get there rather than
jumping ahead now.

### Exit criteria

Gates 1–8 at `✓`, plus: you can open `db/schema.rb:1` cold, pick any table, and say
what each of its indexes is for and which are missing.
```

- [ ] **Step 2: Verify every citation resolves**

Run: `ruby docs/bin/verify_citations.rb docs/learning-plan.md`
Expected: exit 0, `OK`.

- [ ] **Step 3: Verify the quoted snippets and the counts**

```bash
sed -n '33,34p;69p' db/schema.rb
sed -n '74p' app/models/user.rb
sed -n '13p' app/services/users/reset_progress.rb
sed -n '23p' app/models/user.rb
grep -c 't.index' db/schema.rb
grep -c 'add_foreign_key' db/schema.rb
ls db/views/ | wc -l
```
Expected:
```
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
      ActiveRecord::Base.transaction do
      user.transaction do
  belongs_to :path, optional: true, counter_cache: true
64
13
3
```
The counts 64, 13, and 3 appear as claims in the prose — if any differs, update the
prose, not the code.

- [ ] **Step 4: Commit**

```bash
git branch --show-current   # must print: notes
git add docs/learning-plan.md
git commit -m "Chore: author stage 1 gates (the database)"
```

---

### Task 6: Stage 2 gates — ActiveRecord depth

**Files:**
- Modify: `docs/learning-plan.md` — replace `<!-- GATES: filled by Task 6 -->`

**Interfaces:**
- Consumes: the stage body format established in Task 4.
- Produces: nothing new structurally. This is the last task that touches
  `learning-plan.md`.

**Verified constraint discovered during research:** this repo has **no STI and no
`delegated_type`**. Only polymorphic associations are anchorable locally. Do not
invent a citation for the other two.

- [ ] **Step 1: Replace the placeholder with the authored gate section**

Replace the line `<!-- GATES: filled by Task 6 -->` with:

```markdown
### Gate questions

Answer in writing before opening any file. For questions about emitted SQL, write your
prediction down first, then check in `rails console` with `.to_sql` or the log.

1. **Why `source:`.** `app/models/user.rb:14` is
   `has_many :lesson_completions, dependent: :destroy` and line 15 is
   `has_many :completed_lessons, through: :lesson_completions, source: :lesson`. Why
   is `source:` required here but not on a plain `has_many :through`? What does Rails
   try first, and what error do you get if you omit it?

2. **Polymorphic + counter_cache together.** `app/models/like.rb:3` is
   `belongs_to :likeable, polymorphic: true, counter_cache: true`. Name the two
   columns polymorphic requires. Then: why can Postgres not put a foreign key
   constraint on that association, and what does `counter_cache` have to do to find
   the right counter column when the parent could be several different classes?

3. **`inverse_of` is not cosmetic.** `app/models/user.rb:19` is
   `has_many :flags, foreign_key: :flagger_id, dependent: :destroy, inverse_of: :flagger`.
   What does `inverse_of` change at runtime? Construct a concrete two-line console
   session where omitting it produces a stale object or an extra query. Why does Rails
   need to be told here but not for `has_many :likes` on line 21?

4. **`dependent:` in full.** Lines 14–21 of `app/models/user.rb` use
   `dependent: :destroy` six times and `dependent: nil` once, on line 20:
   `has_many :announcements, dependent: nil`. What does `dependent: nil` mean, and why
   write it explicitly rather than omitting the option? What is the difference between
   `:destroy`, `:delete_all`, and `:nullify` in terms of SQL emitted and callbacks run?

5. **Arel in a scope.** `app/models/user.rb:26` is
   `scope :created_after, ->(date) { where(arel_table[:created_at].gt(date)) }`, while
   line 27 is `scope :signed_up_on, ->(date) { where(created_at: date.all_day) }` —
   two different styles in adjacent lines. What does the Arel form give you that
   `where("created_at > ?", date)` does not? Name the specific thing that breaks with
   the string form when the scope is merged into a join.

6. **`includes` and what it decides.** `app/controllers/courses_controller.rb:7` is
   `@sections = @course.sections.includes(:lessons)`. Does `includes` emit one query or
   two? What makes Rails switch between `preload` and `eager_load` behaviour behind it,
   and how do you force each? Which one is wrong if you then call
   `.where(lessons: { … })`?

7. **Two callbacks in the whole app.** This repo has 44 models and exactly two
   ActiveRecord callbacks: `app/models/user.rb:4`, `before_create :enroll_in_foundations`,
   and `app/models/project_submission.rb:5`, `before_update do` in block form.
   Everything else that could have been a callback is a service object — see
   `app/services/users/reset_progress.rb:1`. Why? Name three concrete failure modes of
   callback-heavy models, and say what makes these two the acceptable exceptions. Then:
   why is one written as a symbol and the other as a block — is that a style choice or
   a capability difference?

8. **Optimistic locking.** Nothing in this repo uses it. Describe the exact
   lost-update scenario it solves, name the column Rails looks for, and say what
   exception you get and where you would rescue it. Then say why a course platform can
   get away without it and what kind of feature would force the issue.

### Anchors

| File | Why |
|---|---|
| `app/models/user.rb:1` | 87 lines and the densest association file here — `has_many :through`, `source:`, `foreign_key:`, `inverse_of:`, `as:`, `dependent:`, `counter_cache:`, Arel scopes, and the app's only callback. Read the whole file. |
| `app/models/like.rb:3` | Polymorphic and `counter_cache` on one line |
| `app/models/notification.rb:2` | `belongs_to :recipient, polymorphic: true` — a second polymorphic shape to compare |
| `app/models/concerns/likeable.rb:5` | The `has_many :likes, as: :likeable` other half of the polymorphic pair |
| `app/controllers/courses_controller.rb:7` | `includes` in a real controller action |
| `app/models/project_submission.rb:2` | `include Discard::Model` — soft delete, and how it interacts with `dependent:`; line 5 is the app's other callback |
| `app/services/users/reset_progress.rb:1` | What this app does *instead* of callbacks |

**Not anchorable here.** No STI and no `delegated_type` anywhere in this repo — the
domain never needed either. For gate 8's neighbours, use the Rails Guides on
inheritance and delegated types, and note that the absence itself is data: both
patterns are rarer in production than tutorials suggest.

### Second exposure

**chatwoot**, at stage 6, where account scoping puts every association behind a tenant
boundary — the same association options under a constraint this repo never applies.

### Exit criteria

Gates 1–8 at `✓`, plus: given any association line in `app/models/user.rb:1`, you can
state the SQL it will emit and which columns must exist for it to work.
```

- [ ] **Step 2: Verify every citation resolves**

Run: `ruby docs/bin/verify_citations.rb docs/learning-plan.md`
Expected: exit 0, `OK`.

- [ ] **Step 3: Verify the quoted snippets match**

```bash
sed -n '4p;14,15p;19,21p;26,27p' app/models/user.rb
sed -n '3p' app/models/like.rb
sed -n '2p' app/models/notification.rb
sed -n '5p' app/models/concerns/likeable.rb
sed -n '7p' app/controllers/courses_controller.rb
sed -n '2p;5p' app/models/project_submission.rb
```
Expected, in order:
```
  before_create :enroll_in_foundations
  has_many :lesson_completions, dependent: :destroy
  has_many :completed_lessons, through: :lesson_completions, source: :lesson
  has_many :flags, foreign_key: :flagger_id, dependent: :destroy, inverse_of: :flagger
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :announcements, dependent: nil
  scope :created_after, ->(date) { where(arel_table[:created_at].gt(date)) }
  scope :signed_up_on, ->(date) { where(created_at: date.all_day) }
  belongs_to :likeable, polymorphic: true, counter_cache: true
  belongs_to :recipient, polymorphic: true
    has_many :likes, as: :likeable, dependent: :destroy
    @sections = @course.sections.includes(:lessons)
  include Discard::Model
  before_update do
```

- [ ] **Step 4: Re-confirm the "two callbacks" and "no STI" claims**

```bash
grep -rEn 'before_(save|create|update|validation|destroy)|after_(save|create|update|commit|destroy)' app/models/
grep -rn 'delegated_type\|inheritance_column' app/ | wc -l
```
Expected: exactly two hits —
`app/models/project_submission.rb:5:  before_update do` and
`app/models/user.rb:4:  before_create :enroll_in_foundations` — then `0`. Gate 7 states
"exactly two callbacks" and the anchors state "no STI and no `delegated_type`"; if
either moves, correct the prose.

- [ ] **Step 5: Verify no placeholder markers survive in the file**

```bash
grep -n 'GATES: filled by' docs/learning-plan.md | wc -l
```
Expected: `0`. All three placeholders from Task 3 are now replaced.

- [ ] **Step 6: Commit**

```bash
git branch --show-current   # must print: notes
git add docs/learning-plan.md
git commit -m "Chore: author stage 2 gates (ActiveRecord depth)"
```

---

### Task 7: `docs/progress.md`

**Files:**
- Create: `docs/progress.md`

**Interfaces:**
- Consumes: stage titles and gate counts from `docs/learning-plan.md`.
- Produces: the confidence table format. `interview-prep.md` (Task 9) tells the reader
  to source drill questions from rows marked `~` here.

- [ ] **Step 1: Write the file**

```markdown
# Progress

Confidence, not coverage. Coverage is not what decays.

See [`README.md`](README.md#confidence-marks) for what each mark means. Advancement is
gated: a stage opens when the previous stage's rows are all `✓` or better, however long
that takes.

**An all-`✓` board means the gates are too easy.** `~` rows are the system working.

## Stages

| # | Stage | Confidence | Last tested | Resurface after |
|---|---|---|---|---|
| 0 | Ruby fluency | — | | |
| 1 | The database | — | | |
| 2 | ActiveRecord depth | — | | |
| 3 | Request layer | — | | |
| 4 | Testing / RSpec | — | | |
| 5 | App architecture | — | | |
| 6 | Auth & authorization | — | | |
| 7 | Frontend in Rails | — | | |
| 8 | Async | — | | |
| 9 | Performance | — | | |
| 10 | APIs | — | | |
| 11 | Payments & commerce | — | | |
| 12 | Security | — | | |
| 13 | Ops & deploy | — | | |
| 14 | Real-codebase work | — | | |
| — | CS fundamentals (parallel, ungated) | — | | |

## Gates within the current stage

Replace this block when moving to a new stage. One row per gate question, so a stage
can be partly `✓` without pretending the whole thing is.

**Stage 0 — Ruby fluency**

| Gate | Topic | Confidence | Last tested | Resurface after |
|---|---|---|---|---|
| 0.1 | Blocks / procs / lambdas, `return` semantics | — | | |
| 0.2 | `included do` vs plain module body | — | | |
| 0.3 | `include` vs `extend` | — | | |
| 0.4 | Method lookup, `prepend`, `ancestors` | — | | |
| 0.5 | `Hash.new` with a default block | — | | |
| 0.6 | `\|\|=` and falsy memoization | — | | |
| 0.7 | Keyword args and `foo:` shorthand | — | | |
| 0.8 | `StandardError` vs `Exception`, `rescue_from` | — | | |

## Code written

Gates can keep passing while real ability stalls — this doc set deliberately puts code
practice outside itself, so this is the row that catches the drift. If the last entry
is more than a few weeks old, stop reading and go build something.

| Date | What | Where |
|---|---|---|
| | | |

## Session log

Newest first. One line each: date, what was attempted, what actually happened.

| Date | Stage | What happened |
|---|---|---|
| | | |
```

- [ ] **Step 2: Verify the stage list matches the plan exactly**

```bash
grep -o '^## Stage [0-9]* — .*' docs/learning-plan.md | sed 's/^## Stage [0-9]* — //'
```
Expected: 15 titles, in order, each matching a row in the Stages table above. Any
mismatch is a bug in one of the two files — fix `progress.md`.

- [ ] **Step 3: Verify the gate rows match stage 0's actual gate count**

```bash
awk '/^## Stage 0/,/^## Stage 1/' docs/learning-plan.md | grep -cE '^[0-9]+\. \*\*'
```
Expected: `8`, matching rows 0.1–0.8.

- [ ] **Step 4: Verify citations**

Run: `ruby docs/bin/verify_citations.rb`
Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git branch --show-current   # must print: notes
git add docs/progress.md
git commit -m "Chore: add progress tracker"
```

---

### Task 8: `docs/concepts/` and `docs/questions.md`

Both are capture surfaces with the same trigger — something surfaced mid-session that
should not be lost. Grouped because a reviewer would accept or reject them together.

**Files:**
- Create: `docs/concepts/README.md`
- Create: `docs/concepts/counter-cache.md`
- Create: `docs/questions.md`

**Interfaces:**
- Consumes: the citation convention from `docs/README.md`.
- Produces: the concept-file template — **What it is** / **Where it shows up** /
  **Why here** / **Gotcha** / **Ember contrast** (optional) / **Cited**.
  `questions.md` links answered questions to the concept file they produced.

- [ ] **Step 1: Write `docs/concepts/README.md`**

```markdown
# Concepts

One file per concept, in my own words. Written when a gate fails, or when something
clicks that did not before. Named after the concept in kebab-case: `counter-cache.md`,
`inverse-of.md`, `n-plus-one.md`.

**Revise these files; do not append to them.** A concept file is a current best
understanding, not a log. If a later stage shows the explanation was wrong, rewrite it
— the wrongness is recorded in `progress.md` and `interview-prep.md`, not here.

## Required in every file

- **A citation**, with the line quoted, not only referenced. A file without one is
  unfinished. See [`../README.md`](../README.md#citing-code).
- **Plain language.** If it reads like the Rails Guides, it is copied, not understood.
  The test: could you say this out loud to another developer without reading it?
- **The gotcha.** What actually bites people. If there isn't one, the concept was
  probably too small to deserve a file.

## Encouraged

- **An Ember contrast**, where one genuinely helps. Twenty shipped Ember projects is a
  large amount of transferable structure, and naming the analogy — or naming precisely
  where it breaks down — is faster than building the idea from scratch. Do not force
  it; a bad analogy costs more than none.

## Template

See [`counter-cache.md`](counter-cache.md) for a worked example.

```markdown
# <concept>

**What it is** — two or three sentences.

**Where it shows up** — the citation, with the line quoted.

**Why it's used here** — the actual reason this codebase reached for it.

**Gotcha** — what bites.

**Ember contrast** — optional.
```
```

- [ ] **Step 2: Write `docs/concepts/counter-cache.md` as the worked example**

```markdown
# counter_cache

**What it is** — a denormalised integer column on the *child's* parent table holding
the number of associated rows, maintained by ActiveRecord on create and destroy so
`parent.children.count` becomes a column read instead of a `COUNT(*)`.

**Where it shows up** — `app/models/user.rb:23`:

```ruby
belongs_to :path, optional: true, counter_cache: true
```

The option goes on the `belongs_to` side, which reads backwards at first: the *user*
declares it, but the column `users_count` lives on `paths`. Rails needs the
declaration where the write happens, and the write happens when a user is created.

Also at `app/models/like.rb:3`, combined with polymorphism:

```ruby
belongs_to :likeable, polymorphic: true, counter_cache: true
```

Here the counter column has to exist on *every* table that can be `likeable` — the
association does not know which class it will point at until runtime.

**Why it's used here** — path pages render the number of users on each path. Without
the cache that is a `COUNT(*)` over the users table on every page load, and users is
the largest table in the app.

**Gotcha** — **adding it to a table with existing rows leaves every counter at zero
or NULL.** Rails only maintains the counter from the moment the association writes;
it does not backfill. The migration is two steps, not one:

```ruby
add_column :paths, :users_count, :integer, default: 0, null: false
# then, in a separate step:
Path.find_each { |path| Path.reset_counters(path.id, :users) }
```

Second gotcha: `update_column`-style writes and raw SQL bypass it, so the counter
drifts silently. There is no error — just a wrong number on a page. `reset_counters`
is the repair.

**Ember contrast** — closest thing is a computed property with a cached dependent key,
except the cache lives in Postgres rather than in memory, survives the request, and
has no invalidation mechanism watching it. Ember's tracking would notice the
dependency changed; Postgres will not. That missing invalidation is the entire
gotcha above.
```

- [ ] **Step 3: Write `docs/questions.md`**

```markdown
# Questions

Caught mid-session so they neither get lost nor derail the stage in progress. Write
the question down, keep going, come back.

A question is worth writing down if answering it would take more than about two
minutes. Below that, just answer it.

## Open

| Asked | Question | Came up in |
|---|---|---|
| | | |

## Answered

| Asked | Answered | Question | Result |
|---|---|---|---|
| | | | |

The **Result** column links the concept file the answer produced, e.g.
[`concepts/counter-cache.md`](concepts/counter-cache.md) — or says "no file needed"
when the answer was a one-liner. An answered question with neither is a question that
was not really answered.
```

- [ ] **Step 4: Verify citations resolve and quotes match**

```bash
ruby docs/bin/verify_citations.rb
sed -n '23p' app/models/user.rb
sed -n '3p' app/models/like.rb
```
Expected: verifier exits 0; the two `sed` lines print exactly the code quoted in
`counter-cache.md`:
```
  belongs_to :path, optional: true, counter_cache: true
  belongs_to :likeable, polymorphic: true, counter_cache: true
```

- [ ] **Step 5: Verify the worked example satisfies its own template**

```bash
grep -c '^\*\*' docs/concepts/counter-cache.md
```
Expected: `5` — What it is / Where it shows up / Why it's used here / Gotcha / Ember
contrast. If the count is lower, a required section is missing.

- [ ] **Step 6: Commit**

```bash
git branch --show-current   # must print: notes
git add docs/concepts/ docs/questions.md
git commit -m "Chore: add concepts directory and question queue"
```

---

### Task 9: `docs/interview-prep.md` and `docs/job-search.md`

Split from each other by the spec (§7.6, §7.7) but built together: they are the two
halves of getting hired, and neither is gated by a stage.

**Files:**
- Create: `docs/interview-prep.md`
- Create: `docs/job-search.md`

**Interfaces:**
- Consumes: `docs/progress.md` (drill questions are sourced from `~` rows).
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Write `docs/interview-prep.md`**

```markdown
# Interview prep

**Technical only.** The non-technical half — networking, resume, applying, rates,
contracts — is in [`job-search.md`](job-search.md), because it is used at a different
time and by a different mechanism.

## Tradeoff talking points

The shape of a senior answer is *"chose X over Y because Z, and here is what it cost."*
Not a definition. Interviewers can read definitions.

Fill these from real decisions — ones made in the starter kit, or ones found and
understood in this codebase. A talking point without a specific instance behind it
collapses under one follow-up question.

| Decision | Chose | Over | Because | What it cost |
|---|---|---|---|---|
| Counting associated rows | `counter_cache` column | `COUNT(*)` per request | The parent page renders the count on every load and users is the largest table | Backfill on every existing row, and silent drift when anything writes around ActiveRecord (`app/models/user.rb:23`) |
| | | | | |

## Drill questions

Answered **out loud, no files open.** That constraint is the whole exercise — an answer
you can only produce while reading is not an answer you have.

Source these from gates that failed, not from a list of common interview questions.
`~` rows in [`progress.md`](progress.md) are the queue.

| Question | Source gate | Last drilled | Fluent? |
|---|---|---|---|
| | | | |

## Known weak spots

Honest list. The purpose is to *not discover these live in an interview* — and, second,
to have a good answer ready for "what don't you know yet", which is a question worth
preparing rather than improvising.

This list should never be empty. An empty weak-spot list means it is not being kept
honestly, not that there are no weak spots.

| Area | How weak | Plan | Reassessed |
|---|---|---|---|
| | | | |

### Standing, known at the outset

These are structural — known before any gate was attempted, from the shape of the
experience so far:

- **Production incident experience.** No on-call history, no debugging a live outage.
  Stage 14 addresses the reading-unfamiliar-code half; the incident half cannot be
  simulated and is worth saying plainly rather than talking around.
- **Rails at scale.** Everything studied here is a single-app, single-database shape.
  No sharding, no read replicas, no multi-region.
- **Rails 8 defaults are newer than the last hands-on Rails work** — Solid
  Queue/Cache/Cable, Propshaft, Kamal. Being explicit that these postdate the earlier
  learning is more credible than half-claiming them.
```

- [ ] **Step 2: Write `docs/job-search.md`**

```markdown
# Job search

The **non-technical** half of getting hired. Technical retrieval lives in
[`interview-prep.md`](interview-prep.md).

**Not gated and not stage-dependent.** This work should begin well before the Rails
track finishes — it runs on calendar time and other people's response rates, neither of
which cares how far along the stages are. Starting it at stage 14 would be starting it
about two years late.

Structure follows TOP's *Getting Hired* course
(`db/fixtures/paths/full_stack_rails/courses/getting_hired.rb:1`), with a freelance
section added — TOP targets employment only, and freelancing is a stated goal.

## Preparing

| Item | Status | Notes |
|---|---|---|
| Professional networking — where the people actually are | | |
| Job search strategy — target roles, geography, remote-only? | | |
| What companies want vs. what job posts say | | |
| Personal website / portfolio | | |
| Framing the transition: frontend → fullstack, not "junior again" | | |

That last row is the one that is specific to this situation and the one most likely to
be got wrong. Twenty shipped Ember projects is professional frontend experience; the
Rails work is depth being added to it. The pitch is a frontend developer becoming
fullstack — not someone starting over.

## Applying and interviewing

| Item | Status | Notes |
|---|---|---|
| Collecting job leads — sources, cadence | | |
| Qualifying leads — which are worth the hours | | |
| Resume | | |
| Applying — volume, tracking, follow-up | | |
| Interviewing — behavioural, take-homes, live coding | | |
| Handling an offer — negotiating, comparing, declining | | |

**On DS&A screens:** common in remote hiring specifically, and they arrive on the
company's schedule, not yours. That is why the CS track in
[`learning-plan.md`](learning-plan.md#cs-fundamentals--parallel-track) runs in parallel
rather than at the end.

## Freelance-specific

Not covered by TOP. Everything here is a skill that fails expensively when learned by
doing.

| Item | Status | Notes |
|---|---|---|
| Scoping and estimating work | | |
| Rates — hourly vs day vs fixed-bid vs retainer | | |
| Contracts — scope, payment terms, IP, kill fee | | |
| Client screening — the red flags, and the ability to say no | | |
| Deposits and payment schedules | | |
| Scope creep — how it is handled contractually, not socially | | |

**Estimation is the one that transfers from the technical track.** It is listed in
stage 14's scope for a reason: accurate estimates come from having read enough
unfamiliar codebases to know what "add feature X to an existing app" actually costs.

## Applications log

| Date | Company / client | Role | Via | Status |
|---|---|---|---|---|
| | | | | |
```

- [ ] **Step 3: Verify citations**

```bash
ruby docs/bin/verify_citations.rb
ls db/fixtures/paths/full_stack_rails/courses/getting_hired.rb
```
Expected: verifier exits 0; the file listing succeeds.

- [ ] **Step 4: Verify the interview-prep example citation quotes correctly**

```bash
sed -n '23p' app/models/user.rb
```
Expected: `  belongs_to :path, optional: true, counter_cache: true` — matching the
tradeoff table row that cites it.

- [ ] **Step 5: Commit**

```bash
git branch --show-current   # must print: notes
git add docs/interview-prep.md docs/job-search.md
git commit -m "Chore: add interview prep and job search docs"
```

---

### Task 10: `docs/reference-repos.md` and final verification

**Files:**
- Create: `docs/reference-repos.md`

**Interfaces:**
- Consumes: the `rwr:` citation form from `docs/README.md` and the verifier from
  Task 1.
- Produces: the completed doc set.

- [ ] **Step 1: Confirm the three picks are present locally before writing about them**

```bash
ls -d ~/projects/rails-study/real-world-rails/apps/chatwoot \
      ~/projects/rails-study/real-world-rails/apps/gumroad \
      ~/projects/rails-study/real-world-rails/apps/lobsters
ls ~/projects/rails-study/real-world-rails/apps | wc -l
```
Expected: all three directories listed and non-empty; the count is ~176. If a pick is
missing, run `bin/update` in `real-world-rails` before continuing — do not write
citations against a repo that is not there.

- [ ] **Step 2: Write the file**

```markdown
# Reference repos

Seeing a pattern in one codebase teaches that codebase's version of it — you cannot
separate the concept from local taste. Seeing it in two or three forces the
abstraction, which is the point if the goal is walking into unfamiliar client code.

Past three repos this becomes a research project rather than learning. Hence: this repo
as the primary specimen, three hand-picked apps as deliberate second exposures, and the
remaining ~215 as an on-demand reference library.

Second exposures are also naturally **spaced** — meeting `has_many :through` again in
chatwoot weeks after meeting it here is spaced repetition, which beats massed study.

## Primary specimen — this repo

Rails 8.1, actively maintained, and unusually disciplined: the largest model is 87
lines (`app/models/user.rb:1`), services are under 45 lines, and there are 228 spec
files. Real production hygiene — Sentry, rack-attack, Flipper, sidekiq-cron, VCR,
cuprite.

**What it cannot teach:** the domain is small. A 396-line schema, essentially no API
surface, no money, no multi-tenancy, two ActiveRecord callbacks in 44 models. Those
absences are exactly what the picks below cover — and several of them are worth
noticing as findings in their own right rather than treated only as gaps.

## The picks

### chatwoot — stages 6, 10

**What it is:** open-source customer support platform. Large, actively developed,
commercially backed.

**Serves:** account-scoped multi-tenancy and a real versioned API — the two biggest
structural gaps here. It is also the closest shape to a typical freelance SaaS build,
which makes it the most directly transferable of the three.

**Read:** the `Account` model and how every query is scoped through it; the
`app/controllers/api/v1/` and `v2/` split and what changed between versions; the
serializer layer.

**Not good for:** reading end to end. It is far too large. Use it for targeted
comparison against a specific pattern you have already met here.

### gumroad — stages 11, 1

**What it is:** the creator-commerce platform, open-sourced in 2025. 424 MB.

**Serves:** real payments, payouts, refunds, and money modeling in production —
integer cents, currency handling, invoicing, the reconciliation edge cases. Nothing in
this repo touches money at all.

**Read:** how money columns are typed and constrained in the schema (worth revisiting
stage 1's constraint gates against it), the Stripe integration boundary, and webhook
idempotency handling.

**Not good for:** style. It is an old, large, commercially-pressured codebase and
reads like one. That is itself instructive — but do not mistake it for a model to
imitate.

### lobsters — stage 14, and not before

**What it is:** the link-aggregator running lobste.rs. 8.3 MB — small enough to read
end to end, which is the entire reason it is here.

**Serves:** whole-codebase comprehension. Reading an application in its entirety is a
distinct skill from reading a file, and it is the one that decides how fast you can be
useful on unfamiliar client code.

**Adopted at stage 14 deliberately.** It serves one purpose and would be a distraction
earlier.

**Not good for:** modern patterns. It is deliberately conservative and old-fashioned
Rails — which is, again, representative of what freelance work actually looks like.

## Deliberately not picked

- **mastodon** — excellent for APIs and jobs at scale, but overlaps chatwoot's role.
  Standing candidate if API-at-scale proves undercovered by stage 14.
- **discourse**, **canvas-lms** — too large to read. `grep` targets only.
- **spree**, **solidus** — commerce, but Rails engine architecture is a detour from
  everything else here.

## Using the wider corpus

The remaining ~215 apps are a reference library, not a curriculum. Query them when a
specific question arises — "how do other people structure webhook handlers?" — never
as reading material.

Search with the `/real-world-rails` skill. **Note:**
`~/projects/rails-study/real-world-rails` is not on that skill's default search path
and must be named explicitly in the request.

Refresh submodules with `bin/update` in the `real-world-rails` checkout. Expect
picked-repo paths to drift over months — which is why citations quote the line as well
as numbering it.

## Citing a pick

`` `rwr:chatwoot app/models/account.rb:40` `` — the `rwr:` prefix plus the app
directory name, then the path within that app. `ruby docs/bin/verify_citations.rb`
resolves these against `~/projects/rails-study/real-world-rails/apps/`.
```

- [ ] **Step 3: Run the full verifier across every doc**

Run: `ruby docs/bin/verify_citations.rb`
Expected: exit 0, `OK`, with a checked count in the low dozens. Files under
`docs/superpowers/` are excluded from the default glob, so the spec and this plan are
not counted.

- [ ] **Step 4: Verify every file the README promises now exists**

```bash
ls docs/README.md docs/learning-plan.md docs/progress.md docs/questions.md \
   docs/interview-prep.md docs/job-search.md docs/reference-repos.md \
   docs/concepts/README.md docs/concepts/counter-cache.md docs/bin/verify_citations.rb
```
Expected: all ten listed, no `No such file` errors.

- [ ] **Step 5: Verify no placeholders survive anywhere in the doc set**

```bash
grep -rn 'TBD\|TODO\|FIXME\|GATES: filled by\|Lorem\|XXX' docs/ --include='*.md' \
  | grep -v superpowers/ | wc -l
```
Expected: `0`. (The `superpowers/` exclusion skips this plan file itself and the spec.)

- [ ] **Step 6: Verify stages 3–14 still carry no gate questions**

```bash
awk '/^## Stage 3/,0' docs/learning-plan.md | grep -c '### Gate questions' || true
```
Expected: `0`. Spec §7.2 requires later stages be written on demand.

- [ ] **Step 7: Verify the branch and that `main` is untouched**

```bash
git branch --show-current   # must print: notes
git log --oneline main..notes | head -20
git diff --stat main..notes -- docs/ | tail -1
```
Expected: current branch `notes`; the log shows this plan's commits plus the two spec
commits; the diff stat shows changes only under `docs/`.

- [ ] **Step 8: Commit**

```bash
git add docs/reference-repos.md
git commit -m "Chore: add reference repos doc"
```

---

## Self-Review

**Spec coverage.** Every §7 document maps to a task: §7.1→Task 2, §7.2→Tasks 3–6,
§7.3→Task 7, §7.4→Task 8, §7.5→Task 8, §7.6→Task 9, §7.7→Task 9, §7.8→Task 10.
Mechanism sections are enforced rather than restated: §5.2 (answer before you read) is
the standing instruction at the top of every gate section, §5.3 (citation convention)
is enforced executably by Task 1, §5.5 (confidence marks) is the schema of
`progress.md`, §5.6 (production over consumption) is the "Where the code writing
happens" section plus the "Code written" table, §6.1 (TOP mapping) is a per-stage
**TOP:** line, §6.2 (CS track) is its own section marked ungated, §8 (picks) is Task 10,
§9 (maintenance) is the branch-rules section of the README. §10's six success criteria
are structurally supported: 1 by the standing instruction, 2 by the verifier, 3 by the
explicit "an all-`✓` board means the gates are too easy" note, 4 by the seeded
standing weak-spot list, 5 by the gated-not-scheduled rule, 6 by the "Code written"
table.

**Placeholder scan.** The tables in `progress.md`, `questions.md`,
`interview-prep.md`, and `job-search.md` ship with empty rows by design — they are
capture surfaces, and an empty row is the intended initial state, not an unfinished
one. Every prose section is written in full. `<!-- GATES: filled by Task N -->` markers
are transient within this plan and Task 6 Step 5 plus Task 10 Step 5 assert they are
gone.

**Type consistency.** The verifier's invocation is `ruby docs/bin/verify_citations.rb`
in every task. Citation forms are identical in the README, the verifier regex, and
`reference-repos.md`. Confidence marks `—`/`~`/`✓`/`✓✓` are identical in the spec,
README, and `progress.md`. Stage titles are identical between `learning-plan.md` and
`progress.md`, and Task 7 Step 2 asserts it mechanically.

**Known plan-level risk.** Every anchor in Tasks 4–6 was verified against the working
tree at the time of writing. A `git rebase upstream/main` between now and execution can
move line numbers. Each of those tasks therefore includes an explicit
"verify the quoted snippets match" step whose remedy is to fix the doc, not the code.
