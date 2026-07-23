# Rails Learning Docs — Design Spec

**Date:** 2026-07-23
**Repo:** `theodinproject` fork (`Sadek-1801/theodinproject`), branch `notes`
**Status:** Approved

---

## 1. Goal

A self-contained set of documents that takes the learner from *lapsed tutorial-level
Rails* to *freelance/remote-role-ready fullstack Rails developer*.

The docs live inside the theodinproject fork because that codebase is the primary
**study specimen** — a real, actively maintained production Rails 8.1 app. Concepts
are anchored to real files in it rather than taught in the abstract.

**Scope-complete, time-elastic.** The plan enumerates everything needed. The calendar
is a derived annotation, never a constraint. Estimated total: **~1,060 hours** (±30%)
— 990 h on the main track plus a 70 h parallel CS track — which at ~10 h/week is
roughly two years. Nothing is cut to fit a deadline.

---

## 2. Learner context

Facts the design is built on:

- Completed Michael Hartl's *Learn Enough Ruby* and *Ruby on Rails Tutorial*, **late
  2024**. Real foundation: MVC, REST routing, migrations, ActiveRecord basics,
  `has_many :through`, and **hand-rolled authentication** (sessions, password digests,
  remember tokens, activation, resets).
- **Mar 2025 → present:** working as a frontend developer in Ember.js. 20+ shipped
  frontend projects. Engineering instincts are current; only the Ruby/Rails surface
  has decayed.
- Rails knowledge is therefore **~1.5–2 years lapsed and tutorial-shaped**.

Four gaps follow directly from that history and shape the curriculum:

1. **RSpec is new material, not review.** Hartl teaches minitest; this repo has 228
   RSpec files. Treated as a first-time-learning stage, placed early.
2. **Rails 8 ≠ the Rails learned.** Solid Queue/Cache/Cable, Propshaft, importmap,
   Kamal, and the Rails 8 auth generator all postdate the books.
3. **Tutorial-shaped, not codebase-shaped.** One guided app built; never had to
   navigate ~180 unfamiliar model files to find where a behaviour lives. This is most
   of what freelance work actually is.
4. **Never covered at all:** service objects/POROs, concerns, authorization,
   background jobs, caching, N+1/indexes, ViewComponent, Hotwire.

**Design consequence:** pitch at *review* level — prompt recall, fill gaps — except
for stages 4, 10, 11, and 14, which are genuinely new and are taught from zero.

---

## 3. Non-goals

- **Not coupled to the starter kit.** `~/projects/starter-kit/rails-template` is
  already fully planned via its own `ROADMAP.md` and design spec. These docs address
  learning only, and neither plan's schedule may depend on the other's. Naming the kit
  as one of the places code practice happens (§5.6) is a statement of fact, not a
  dependency: no stage waits on a kit phase, and no kit phase waits on a stage.
- **Not a contribution to upstream TheOdinProject.** Lives on `notes` only.
- **Not a curriculum built from real-world-rails.** That corpus is a *reference
  library*, plus a source of 2–3 hand-picked second-exposure repos. It is not
  something to work through.
- **Not exhaustive Rails coverage for its own sake.** Every stage earns its place by
  serving employability or the stage above it.

---

## 4. Location and branch strategy

```
theodinproject/                    (fork; branch: notes)
└── docs/
    ├── README.md                  map of the doc set
    ├── learning-plan.md           the spine: stages, gates, estimates
    ├── progress.md                confidence per stage; gates advancement
    ├── questions.md               running queue of open questions
    ├── interview-prep.md          technical retrieval under pressure
    ├── job-search.md              the non-technical hiring process
    ├── reference-repos.md         the hand-picked apps and what each is for
    ├── concepts/                  one file per concept, in the learner's words
    └── superpowers/specs/         this spec
```

`docs/` does not exist in `upstream/main`, so `git rebase upstream/main` on `notes`
stays conflict-free. If upstream ever introduces its own `docs/`, the fallback is to
rename this tree to `_learning/` — a one-commit change.

**Rules:**
- All learning work happens on `notes`.
- Contributions to upstream branch from `main`, never from `notes`.
- Commit messages on `notes` follow the repo's existing convention
  (`Chore: …` / `Feature: …` / `Fix: …`) so the branch stays tidy, even though it is
  never upstreamed.

---

## 5. The learning mechanism

### 5.1 The problem being solved

For a *review* learner, gaps are invisible. Recognition, recall, and ability to
produce are three different levels, and lapsed knowledge decays to the first while
still feeling like the third. The mechanism's primary job is **making invisible gaps
visible, cheaply and early** — not delivering content.

### 5.2 Answer before you read

Every stop in the plan opens with **gate questions** that must be attempted *before*
opening the referenced code.

Retrieval beats re-reading: attempting an answer — even a wrong one — does more for
retention than reading the correct one, and it primes the subsequent read so you are
checking a hypothesis instead of skimming. **The attempt is the learning; the
pass/fail signal is a side benefit.**

Gate questions must be:
- **Specific enough to fail cleanly.** "Do I understand associations?" is useless.
  "What breaks if you add `counter_cache` to a table that already has rows?" is not.
- **Answerable in 2–5 minutes**, in writing or out loud.
- **Anchored** to a named file to read immediately afterwards.

### 5.3 Anchoring to real code

Abstract facts are hard to retrieve; scenes are not. Each concept is tied to a
production instance in this repo — for example `belongs_to :path, counter_cache: true`
in `app/models/user.rb`, where someone had an actual reason.

**Citation convention** (mandatory on every note):
- This repo: `app/models/user.rb:23`
- A picked repo: `rwr:chatwoot app/models/account.rb:40`

A note without a citation is considered unfinished — citations are what keep notes
verifiable as both codebases move.

### 5.4 Second exposures and transfer

Seeing a pattern once teaches one codebase's version of it; you cannot separate the
concept from local taste. Seeing it in **two or three** codebases forces the
abstraction — that is *transfer*, and transfer is the point if the goal is walking
into unfamiliar client code.

Past three repos, returns diminish and it becomes a research project. Hence: TOP as
primary, 2–3 hand-picked apps as deliberate second exposures, and the remaining ~215
apps as an on-demand reference library.

Second exposures are also naturally **spaced** — meeting `has_many :through` again in
Chatwoot weeks after meeting it here is a spaced repetition, which beats massed study.

### 5.5 Confidence, not coverage

`progress.md` records **confidence**, because coverage is not what decays. Scale:

| Mark | Meaning | Action |
|---|---|---|
| `—` | Not started | — |
| `~` | Attempted, shaky | Resurface after ~3 weeks |
| `✓` | Gate passed | Re-test at second exposure |
| `✓✓` | Re-passed after a gap | Durable; stop revisiting |

Advancement is **gated, not scheduled**: stage *n+1* opens when stage *n*'s gates are
at `✓` or better, regardless of elapsed time.

### 5.6 Production over consumption

Reading is consumption. The minimum viable production step is writing the concept in
your **own words** in `docs/concepts/`. If it cannot be written plainly, it was not
understood. This is the highest-value and least enjoyable part of the system, and the
first thing likely to be abandoned — `interview-prep.md` is the corrective, because
explaining out loud exposes what silent reading hides.

**Code-writing practice lives outside this doc set — deliberately** (decided
2026-07-23). Two outlets already exist and neither needs reinventing:

- **TOP's own curriculum projects** — 15 Ruby and 11 Rails projects (Micro-Reddit,
  Members Only, Flight Booker, Odin Book, …), already sequenced and free. See §6.1.
- **The starter kit** (`~/projects/starter-kit/rails-template`), built on its own
  independent plan.

No per-stage exercises are invented here. That means these docs are a *reading and
recall* system by design, not a complete pedagogy — they are one half of a pair, and
the other half is a real editor with real code in it. If practice lapses, the gates
will still pass while actual ability stalls; that is the known failure mode of this
split, and the reason §10 requires the weak-spot list to stay honest.

### 5.7 Known costs (accepted)

- Gates add friction; some sessions will feel like homework.
- Self-rated confidence is noisy and will overrate. Second exposures and interview
  drilling are the correction.
- The system is only as good as its gate questions.

---

## 6. The curriculum

Dependency-ordered. Each stage depends only on earlier ones. Bracketed items are
gaps this repo **cannot** teach — they are where picked repos are used.

| # | Stage | Contents | Est. h |
|---|---|---|---|
| 0 | **Ruby fluency** | blocks/procs/lambdas/`yield`, modules & mixins, `include`/`extend`/`prepend`, method lookup & `self`, Enumerable, exceptions, light metaprogramming (`define_method`, `send`, `method_missing`), Ruby 3 idiom (keyword args, safe navigation, pattern matching) | 70 |
| 1 | **The database** | relational modeling, SQL joins/aggregates/subqueries/`GROUP BY`, indexes (B-tree, composite, partial), `EXPLAIN` & query plans, transactions & isolation & locking, constraints (FK/unique/check/NOT NULL), migrations, reversibility, backfills, zero-downtime | 90 |
| 2 | **ActiveRecord depth** | association options in full, scope composition & `merge`, `includes`/`preload`/`eager_load`/`joins` and when each, callbacks and why to avoid them, validations & custom validators, STI vs polymorphic vs delegated types, `counter_cache`, `touch`, optimistic locking, query objects, Arel basics | 80 |
| 3 | **Request layer** | Rack & the middleware stack, routing depth (constraints, nesting, concerns, defaults), filters, strong params, sessions & cookies & CSRF, status codes & redirects, caching headers, content negotiation | 45 |
| 4 | **Testing / RSpec** *(new)* | `describe`/`context`/`it`, matchers, model & request & system specs, FactoryBot, shoulda-matchers, stubs & mocks, VCR/WebMock for external APIs, Capybara + cuprite, what to test, coverage vs confidence, TDD workflow | 90 |
| 5 | **App architecture** | model & controller concerns, service objects/POROs, form objects, query objects, presenters/decorators, ViewComponent, value objects, and the judgment of which to reach for | 70 |
| 6 | **Auth & authorization** | Devise mapped onto existing hand-rolled knowledge, OmniAuth/OAuth2 flows, 2FA, sessions vs tokens, Pundit/CanCanCan/custom RBAC, **[multi-tenancy scoping]** | 70 |
| 7 | **Frontend in Rails** | Turbo Drive/Frames/Streams, Stimulus, Propshaft, importmap, js/cssbundling, ViewComponent + Lookbook, when real JS is warranted | 50 |
| 8 | **Async** | ActiveJob abstraction, Sidekiq vs Solid Queue, idempotency, retries & backoff, dead-letter handling, cron/scheduled jobs, ActionCable & Turbo Stream broadcasting | 55 |
| 9 | **Performance** | rack-mini-profiler, stackprof, fragment & russian-doll caching, low-level & HTTP caching, Solid Cache, Bullet, N+1 in practice, memory & GC basics | 70 |
| 10 | **APIs** *(new)* | REST design, versioning, serializers (jbuilder/alba/AMS), token auth, rate limiting, webhooks in both directions, GraphQL awareness — **[all of it]** | 65 |
| 11 | **Payments & commerce** *(new)* | Stripe charges/subscriptions/webhooks/idempotency, the `pay` gem, money modeling in integer cents & currency, invoicing, refunds, taxes, PCI awareness — **[all of it]** | 70 |
| 12 | **Security** | OWASP Top 10 in Rails terms, mass assignment, SQL injection, XSS in ERB, CSRF, credentials & secrets, Brakeman, bundler-audit, rack-attack | 45 |
| 13 | **Ops & deploy** | Docker, Kamal, env & credentials, zero-downtime migrations in production, backups, Sentry & monitoring, log aggregation, CI/CD | 60 |
| 14 | **Real-codebase work** *(new)* | reading unfamiliar code fast, Rails version upgrades, legacy patterns & deprecations, debugging production issues, estimation & scoping | 60 |

**Main track ≈ 990 h.** Plus the 70 h parallel CS track (§6.2) = **≈ 1,060 h total.**

Cross-cutting topics are folded in where they naturally arise rather than given their
own stages: ActiveStorage, ActionMailer, i18n, ActiveSupport, Git/PR workflow.

**Ordering rationale.** Stage 1 precedes 2 because ActiveRecord without SQL produces
working code over a badly modeled schema — the characteristic failure of frontend
developers moving to backend. Stage 4 is early despite being new material so that
every later stage can be practised through tests. Stage 7 is cheap because Ember
experience transfers almost directly.

### 6.1 Relationship to TOP's own curriculum

The learner is also working **TOP's Full Stack Ruby on Rails path**. The two are
complementary rather than competing, and the split is asymmetric: TOP is breadth-first
and **project-driven**; this plan is depth-first and **codebase-driven**. TOP takes you
to junior; this plan takes you to hireable-professional. Where TOP covers a stage, use
**TOP's lessons and projects as the guided path** and use this plan's gates only to
verify retention — do not re-derive material TOP already sequences well.

Course outline below is taken from this repo's own seed fixtures
(`db/fixtures/paths/full_stack_rails/courses/`), not from marketing copy.

| Stage | TOP coverage | Verdict |
|---|---|---|
| 0 Ruby fluency | Ruby → *Advanced Ruby* (Blocks, Pattern Matching, Custom Enumerables), *OOP Basics* | **Use TOP.** Skip *Basic Ruby* — below level after Hartl. |
| 1 Database | Databases → 3 lessons total (*Databases*, *Databases and SQL*, *SQL Zoo*) | **Badly insufficient.** No indexes, `EXPLAIN`, transactions, locking, or constraints. TOP is a starting point; this plan's 90 h carries it. |
| 2 ActiveRecord | Rails → *Active Record Basics*, *Advanced Forms and Active Record* (Queries, Associations, Callbacks). Projects: Micro-Reddit, Private Events, Flight Booker | **Use TOP** for the guided path; this plan adds `includes`/`preload`/`eager_load`, STI vs delegated types, optimistic locking, Arel. |
| 3 Request layer | Rails → *Rails Basics* (Routing, Controllers, Views, Store App) | **Use TOP.** This plan adds Rack/middleware depth. |
| 4 Testing / RSpec | Ruby → *Testing Ruby with RSpec* (TDD, Intro to RSpec, Connect Four) | **Partial.** Teaches RSpec on plain Ruby only. Rails-specific request/system specs, FactoryBot, VCR, cuprite remain this plan's work. |
| 5 App architecture | — | **Nothing.** Entirely this plan. |
| 6 Auth & authz | Rails → *Forms and Authentication* (Sessions, Cookies and Authentication; Members Only!) | **AuthN only, hand-rolled.** No Devise, no OmniAuth, no authorization at all. |
| 7 Frontend in Rails | Rails → *Assets and Navigation* (Asset Pipeline, Importmaps, Turbo Drive) + *Rails Sprinkles* (CSS/JS Bundling, Turbo, Stimulus) | **Use TOP.** Good coverage. |
| 8 Async | Rails → *Mailers and Advanced Topics* (Websockets and ActionCable) | **Partial.** ActionCable only; no job queues, idempotency, or retries. |
| 9 Performance | — | **Nothing.** |
| 10 APIs | Rails → *APIs* (Building Your Own, External APIs, Kittens API, Pexels API) | **Decent start.** This plan adds versioning, serializers, token auth, rate limiting. |
| 11 Payments | — | **Nothing.** |
| 12 Security | — | **Nothing.** |
| 13 Ops & deploy | Rails → *Deployment* (one lesson) | **Minimal.** |
| 14 Real-codebase work | — | **Nothing.** TOP is greenfield-only by design. |

Also worth taking from TOP outside the stage structure: **Ruby → *Intermediate Git***
(remotes, "Git in the Real World"), which this plan otherwise treats as assumed.

**Skip** TOP's *Intermediate/Advanced HTML and CSS*, *JavaScript*, and *React* courses
— already covered by 20+ shipped Ember projects. React only if a specific job demands
it, and then as a job requirement, not as learning.

**Net:** TOP substantially covers stages 0, 2, 3, 7 and partly 4, 6, 10. This plan's
irreducible value is stages **1, 5, 8, 9, 11, 12, 13, 14** — the production-Rails
material no free curriculum teaches.

### 6.2 Parallel track — CS fundamentals for interviews

| Track | Contents | Est. h |
|---|---|---|
| **CS-I** | A very brief intro to CS, recursive methods & recursion, time complexity, space complexity, common data structures & algorithms, linked lists, hashmaps, binary search trees, Knight's Travails | 70 |

Sourced directly from TOP's Ruby course, section *A Bit of Computer Science*, which is
already sequenced and project-backed.

**Run in parallel, not as a terminal stage.** Placing it after stage 14 would put it
roughly two years out, which is useless — DS&A screens are common in **remote** hiring
and are needed *before* the Rails depth is finished, not after. Schedule it as a
recurring slice (e.g. one session in four) whenever job applications are active.

This track is exempt from the §5.5 gating rule: it does not block or depend on any
Rails stage.

---

## 7. Documents

### 7.1 `docs/README.md`
Map of the set: what each file is for, the workflow, the citation convention, and the
branch rules from §4. Short — it is a signpost, not content.

### 7.2 `docs/learning-plan.md`
The spine. One section per stage, each containing:
- **Goal** — one sentence on what competence looks like at the end.
- **Gate questions** — 4–8 per stage, meeting the §5.2 criteria.
- **Anchors** — specific files in this repo, with line ranges.
- **Second exposure** — which picked repo revisits this, if any.
- **Estimate** — hours, flagged as ±30%.
- **Exit criteria** — what must be at `✓` to advance.

Stages are written **on demand, not upfront**: stage *n+1* is authored as stage *n*
nears completion, so gate questions reflect what has actually proven weak. The initial
build authors stages 0–2 in full; later stages exist as headings plus scope until
reached.

### 7.3 `docs/progress.md`
A table: stage · topic · confidence mark · date last tested · resurface-after date.
Plus a short dated log of sessions. This is the scheduling data for §5.5 — without it
there is no spacing.

### 7.4 `docs/concepts/`
One file per concept, in the learner's own words, created when a gate fails or a
concept clicks. Required: a citation, a plain-language explanation, and — where it
helps — an Ember contrast. Files are revised as understanding deepens rather than
appended to.

### 7.5 `docs/questions.md`
Two lists: **Open** and **Answered** (with date and resulting concept file). Catches
mid-session curiosity so it is neither lost nor allowed to derail the stage in
progress.

### 7.6 `docs/interview-prep.md`
**Technical only.** Three sections:
- **Tradeoff talking points** — "chose X over Y because Z", the shape of a senior
  answer.
- **Drill questions** — answered out loud, no files open. Sourced from failed gates.
- **Known weak spots** — honest list, so it is not discovered live in an interview.

### 7.7 `docs/job-search.md`
The **non-technical** half of getting hired, split out from §7.6 because it is used at
a different time, by a different mechanism, and is not gated by any stage. Seeded from
TOP's *Getting Hired* course (`db/fixtures/paths/full_stack_rails/courses/getting_hired.rb`):

- **Preparing** — professional networking, strategy, what companies want, personal site.
- **Applying** — collecting and qualifying job leads, resume, applying, interviewing,
  handling an offer.
- **Freelance-specific** — scoping and estimating work, rates, contracts, client
  screening. Not covered by TOP, which targets employment; added here because
  freelancing is a stated goal.

Deliberately not gated and not stage-dependent: this work should begin well before the
Rails track finishes.

### 7.8 `docs/reference-repos.md`
The 2–3 picks, each with: what it is, which stages it serves, specific paths worth
reading, and what it is *not* good for. Plus how to use the wider corpus on demand,
including that `~/projects/rails-study/real-world-rails` is not on the
`/real-world-rails` skill's default search path and must be named explicitly.

---

## 8. Reference repos

Primary specimen: **this repo** — Rails 8.1, actively maintained, disciplined (largest
model 87 lines), 228 spec files, strong production hygiene (Sentry, rack-attack,
Flipper, sidekiq-cron, VCR, cuprite). Small domain: 396-line schema, services under 45
lines, essentially no API surface.

Picks from `real-world-rails` (all verified present locally):

| Repo | Serves stages | Why |
|---|---|---|
| **chatwoot** (157 MB) | 6, 10 | Account-scoped multi-tenancy and a real versioned API — the two biggest structural gaps here. Closest shape to a typical freelance SaaS build. |
| **gumroad** (424 MB) | 11, 1 | Real payments, payouts, and money modeling in production. Nothing in this repo touches money. |
| **lobsters** (8.3 MB) | 14 | Small enough to read end-to-end, which is the only way to practise whole-codebase comprehension. Adopted at stage 14, not before — it serves one purpose and would be a distraction earlier. |

Deliberately not picked: **mastodon** (excellent for API/jobs at scale, but overlaps
chatwoot's role), **discourse**/**canvas-lms** (too large to read; `grep` targets
only), **spree**/**solidus** (commerce, but engine architecture is a detour).

The remaining ~215 apps stay an on-demand reference library, queried via the
`/real-world-rails` skill when a specific question arises.

---

## 9. Maintenance

- **Rebase, don't merge:** `git fetch upstream && git rebase upstream/main` on `notes`.
  Because `docs/` is additive and untouched upstream, this stays conflict-free.
- **Citations rot.** Both codebases move. Line numbers are best-effort; the file path
  plus a quoted snippet is the durable part. Notes should quote the line, not only cite it.
- **`bin/update`** in `real-world-rails` refreshes submodules; expect picked-repo paths
  to drift over months.
- Prune ruthlessly. A concept at `✓✓` that has stopped being revisited can be archived.

---

## 10. Success criteria

The system is working if, at any point:

1. Every stage marked `✓` has a gate that was genuinely attempted before reading.
2. Every concept file carries a citation and is written in the learner's own words.
3. `progress.md` contains `~` marks — an all-`✓` board means the gates are too easy.
4. `interview-prep.md` weak-spot list is non-empty and honest.
5. Advancement has been gated by confidence, never by elapsed time.
6. **Code has been written recently** — a TOP project or a starter-kit phase within
   the last few weeks. Because §5.6 puts practice outside this doc set, gates can keep
   passing while real ability stalls; this is the criterion that catches it.

It has failed if it becomes a reading list with ticks next to it.

---

## 11. Deferred

- **Spaced-repetition tooling** (Anki export, scripts). `progress.md` dates are
  sufficient until proven otherwise; automate only if manual tracking actually lapses.
- **Additional docs** beyond §7 — added when a concrete need appears, not upfront.
- **A fourth picked repo** beyond chatwoot/gumroad/lobsters — only if a gap survives
  stages 0–14. Mastodon is the standing candidate if API-at-scale proves undercovered.
