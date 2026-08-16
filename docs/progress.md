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
| 0.1 | Blocks / procs / lambdas, `return` semantics | ~ | 2026-07-26 | 2026-08-16 |
| 0.2 | `included do` vs plain module body | ~ | 2026-07-26 | 2026-08-16 |
| 0.3 | `include` vs `extend` | ~ | 2026-07-26 | 2026-08-16 |
| 0.4 | Method lookup, `prepend`, `ancestors` | ~ | 2026-07-26 | 2026-08-16 |
| 0.5 | `Hash.new` with a default block | ✓ | 2026-08-04 | 2nd exposure |
| 0.6 | `\|\|=` and falsy memoization | ~ | 2026-08-09 | 2026-08-30 |
| 0.7 | Keyword args and `foo:` shorthand | ✓ | 2026-08-09 | 2nd exposure |
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
| 2026-08-09 | 0 | Gate 0.7: clean cold pass, 3/3. (a) `exists?(user:)` → `exists?(user: user)`, punned from the `liked_by?(user)` param. (b) Ruby 3.1 (correct). (c) got the symbol-literal vs keyword-label distinction cold (colon-left = value, colon-right = param name); sharpened only the "why has_many uses a symbol" (open-ended name = data → symbol; known config switch → keyword). Wrote concepts/keyword-argument-shorthand.md. Marked ✓ — first cold pass since 0.5. |
| 2026-08-09 | 0 | Gate 0.6: (a) poison value = `nil`/`false` — correct cold. (b) "a boolean" — right neighborhood but incomplete; didn't check that the three *memoized* methods all return Array/Integer (truthy, `0` included), so NONE hit the trap, and the boolean methods that could (`started?`/`completed?`) are deliberately unmemoized. Closed the gap through discussion + writing two LinkedIn posts (`!!0 => true`, false-never-caches). Wrote concepts/or-equals-memoization.md. Marked ~ (cold attempt partial; concept now ✓). |
| 2026-08-04 | 0 | Gate 0.5: first gate passed cold on the written attempt. (a) block fires on a missing key, (b) once across three same-key lookups because `hash[c] =` stores it, (c) dropping the assignment turns the cache into a factory — right direction, sharpened to the concrete consequence (new object every call, inner caches lost). Ran the object_id/size repro, all four matched. Wrote concepts/hash-default-block.md. Marked ✓. |
| 2026-07-26 | 0 | Gate 0.4: (a)/(b) cold — include puts module after class, prepend before, first match in `ancestors` wins. (c) had the right tools (owner, source_location) but wrong handle — must grab `obj.method(:x)`/`Class.instance_method(:x)` first, not call the method. Wrote concepts/method-lookup-and-reflection.md. Marked ~. |
| 2026-07-26 | 0 | Gate 0.3: extend half of the rule was fuzzy; called `.ancestors` a list of methods (it's modules). Ran the irb repro — seeing `Concernish` sit 2nd in `singleton_class.ancestors` made it click: extend = insert into singleton chain, which is why `included` resolves. Wrote concepts/include-vs-extend.md. Marked ~. |
| 2026-07-26 | 0 | Gate 0.2: receiver pairing right (has_many→class, liked_by? body→record). Missed *why* bare `has_many` fails — it's a load-time NoMethodError on the bare module, not misattachment. Sharpened concepts/included-do-and-self.md (corrected my own "wrong thing" imprecision). Marked ~. |
| 2026-07-26 | 0 | Gate 0.1: `return` proc-vs-lambda and `yield`/no-block both solid (named guard `has_block?`, actually `block_given?`). `self` inside `included do` missed — said "instance", it's the including class. Wrote concepts/included-do-and-self.md. Marked ~. |
