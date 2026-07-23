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
