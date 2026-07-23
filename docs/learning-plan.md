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
| `app/models/concerns/likeable.rb:1` | 32 lines; covers `extend ActiveSupport::Concern`, `included do`, blocks, and instance methods in one readable unit. Read the whole file. |
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
   `add_foreign_key` lines, across 23 ActiveRecord models. Name three things that can go wrong in a
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

3. **`inverse_of` is not cosmetic.** `app/models/user.rb:18` is
   `has_many :flags, foreign_key: :flagger_id, dependent: :destroy, inverse_of: :flagger`.
   What does `inverse_of` change at runtime? Construct a concrete two-line console
   session where omitting it produces a stale object or an extra query. Why does Rails
   need to be told here but not for `has_many :likes` on line 21?

4. **`dependent:` in full.** Lines 14–21 of `app/models/user.rb` use
   `dependent: :destroy` six times and `dependent: nil` once, on line 20:
   `has_many :announcements, dependent: nil`. What does `dependent: nil` mean, and why
   write it explicitly rather than omitting the option? What is the difference between
   `:destroy`, `:delete_all`, and `:nullify` in terms of SQL emitted and callbacks run?

5. **Arel in a scope.** `app/models/user.rb:25` is
   `scope :created_after, ->(date) { where(arel_table[:created_at].gt(date)) }`, while
   line 26 is `scope :signed_up_on, ->(date) { where(created_at: date.all_day) }` —
   two different styles in adjacent lines. What does the Arel form give you that
   `where("created_at > ?", date)` does not? Name the specific thing that breaks with
   the string form when the scope is merged into a join.

6. **`includes` and what it decides.** `app/controllers/courses_controller.rb:7` is
   `@sections = @course.sections.includes(:lessons)`. Does `includes` emit one query or
   two? What makes Rails switch between `preload` and `eager_load` behaviour behind it,
   and how do you force each? Which one is wrong if you then call
   `.where(lessons: { … })`?

7. **Two callbacks in the whole app.** This repo has 23 ActiveRecord models and exactly two
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
are this stage's work. This repo has 163 spec files to read.

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
