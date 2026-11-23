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

TOP's Ruby course comes first. See Stage 0 in `learning-plan.md` for the steps.

| Step | TOP section | Status |
|---|---|---|
| 1 | Basic Ruby | — |
| 2 | Basic Ruby Projects | — |
| 3 | Object Oriented Programming, Tic Tac Toe, Mastermind | — |
| 4 | Advanced Ruby | — |

The gates are paused until step 4 is done. Their resurface dates no longer apply.

| Gate | Topic | Confidence | Last tested | Resurface after |
|---|---|---|---|---|
| 0.1 | Blocks / procs / lambdas, `return` semantics | ✓✓ | 2026-08-27 | 2026-09-27 |
| 0.2 | `included do` vs plain module body | ✓✓ | 2026-08-31 | 2026-09-30 |
| 0.3 | `include` vs `extend` | ✓✓ | 2026-08-31 | 2026-09-30 |
| 0.4 | Method lookup, `prepend`, `ancestors` | ✓ | 2026-09-10 | 2026-09-24 |
| 0.5 | `Hash.new` with a default block | ✓ | 2026-09-10 | 2026-09-24 |
| 0.6 | `\|\|=` and falsy memoization | ~ | 2026-09-15 | 2026-09-29 |
| 0.7 | Keyword args and `foo:` shorthand | ✓ | 2026-08-23 | 2nd exposure |
| 0.8 | `StandardError` vs `Exception` (`rescue_from` moved to Stage 3) | ~ | 2026-08-23 | 2026-09-13 |

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
| 2026-11-23 | 0 | Paused the gates. Stage 0 was pitched as review of Hartl, but basic Ruby was never solid, so the gates kept testing unlearned material. Stage 0 now starts with TOP's Ruby course at *Basic Ruby*; the gates resume after *Advanced Ruby*. Moved `rescue_from` to Stage 3. |
| 2026-09-15 | 0 | Gate 0.6 re-test (was ~ from 2026-08-23), held at ~ — real improvement, not clean. (a) desugar `@x || (@x = expr)` fine, but didn't name the exact falsy set cold (`nil`/`false` only; `0`/`""`/`[]` truthy) — needed a nudge, and that precision *is* the gate. (b) the strong one, cold: truthy-types-are-safe reasoning correct, named the boolean-return danger; I added the design payoff (started?/completed? deliberately unmemoized because they can return false). (c) diagnosis right (false recomputes forever, no error) but the *fix* was wrong cold ("return string/number") and the `defined?` mechanism only landed after I traced it. Sharpened or-equals-memoization.md with the missing (c): the `defined?`-guard idiom, "||= tests the value's truthiness, defined? tests the variable's assignment — state vs value." Resurface 2026-09-29 (2wk). |
| 2026-09-10 | 0 | Gate 0.5 re-test (2nd exposure, held at ✓). (b) once-per-key + (c) factory-vs-cache core solid cold — drill confirmed 3× `0`, block runs every read, hash stays `{}`. (a) wobbled: told the memoization story but didn't isolate the trigger. Sharpened nothing — hash-default-block.md already leads with "fires only on a missing key... the only trigger" (lines 11-13); decay was in recall, not the note. Resurface 2026-09-24 (2wk) to retest the trigger-naming cold. |
| 2026-09-10 | 0 | Gate 0.4 re-test (was ~ from 2026-07-26), marked ✓ — leaned on the drill. (a) include→after class, prepend→before: clean cold. (b) outcome clean cold; the *rule* ("first match down `ancestors` wins", prepend wins by sitting ahead, `super` reaches back) needed one nudge to name. (c) the July "wrong handle" spot — went blank cold, re-derived via drill: `p.hi.owner` is the trap (calls the method, `.owner` runs on the returned string); right handle is `p.method(:x)` / `Class.instance_method(:x)`, then `.owner`/`.source_location`. Key surprise that stuck: `.owner` returns the *defining* module (`Greet`/`Likeable`), not the class you called on. Sharpened method-lookup-and-reflection.md with the "who you asked vs who answered" fact. Resurface 2026-09-24 (2wk) since (c) still decays. |
| 2026-08-31 | 0 | Gate 0.3 re-test, clean cold pass 3/3 (was ~ from 2026-07-26). (a) include→instance, extend→class methods — right cold, via Drill A (Inc.new.hello vs Ext.hello). (b) first misattributed has_many to `extend ActiveSupport::Concern`; caught it via Drill B (toy Concernish/Likeableish) — extend gives the module the `included`-hook machinery (module responds to `included`), has_many is ActiveRecord's and resolves against the model, not from Concern. (c) the July fuzzy spot, now solid: `extend M` puts M in `C.singleton_class.ancestors` not `C.ancestors`, and `ancestors` is a list of modules not methods. Sharpened include-vs-extend.md with the `extend M ≡ singleton_class.include M` identity. Marked ✓✓. |
| 2026-08-31 | 0 | Gate 0.2 re-test, clean cold pass 3/3 (was ~ from 2026-07-26). (a) finally stated as the *receiver* rule, not timing: line goes in `included do` when self is the including class (which responds to has_many), in the body when self is the module (which doesn't) — got there after being pushed off "build vs called" timing language. (b) ran `module Demo; has_many; end` in bare irb: NoMethodError, receiver = the module, bottom `puts` never printed → dies at load-time. (c) the discriminator — predicted a bare `def` inside `class_eval`/`included do` stays an instance method (Widget.new.hello works, Widget.hello raises), naming the second rebind (self AND default definee). Sharpened concepts/included-do-and-self.md with the two-rebinds fact; wrote concepts/polymorphic-likeable.md from the side-question on `as: :likeable` (one likes table, likeable_id + likeable_type, dependent: :destroy). Marked ✓✓. |
| 2026-08-27 | 0 | Gate 0.1(c) re-derivation (the recurring `self`-in-`included do` miss). Diagnosed 0.1(c)/0.2/0.8(c) as one blind spot — execution-context/timing facts that decay because rereading stores a sentence, not a trace. Fix: re-derive, don't re-read. Traced a toy `Trackable`/`Widget` concern cold in irb — predicted print order D,A,B,C correctly; learned `base.class_eval` (rebinds `self` + default definee to the class); derived the killer anchor unaided: at include-time no instance exists yet (no `.new` has run), so `self` can't be an instance — wrong clock. Connected back to likeable.rb (load-time `included do` self=class → `has_many` works; run-time methods self=record → `self.liked = true` works). Sharpened concepts/included-do-and-self.md with the class_eval mechanism + two-clocks anchor. First clean cold pass on (c) after a gap → ✓✓. |
| 2026-08-23 | 0 | Gate 0.8: (b) `rescue Exception` swallows Ctrl-C/signals → can't kill process — clean. (a) knew StandardError=recoverable vs Exception=root but didn't name the above-StandardError errors (Interrupt/SystemExit/NoMemoryError/ScriptError) — thin. (c) two slips: attributed rescue_from to ActiveRecord (it's ActiveSupport::Rescuable; ActiveRecord only supplies the exception arg), and called `rescue` a "method-level catcher" (it's a keyword tied to a block) — missed keyword-vs-registered-method and register-at-load vs catch-at-request timing; had the scope distinction (controller-wide vs local) right. Wrote concepts/standard-error-vs-exception.md. Marked ~. |
| 2026-08-23 | 0 | Gate 0.7: clean cold pass, 3/3. (a) `exists?(user:)` → `exists?(user: user)`, punned from the `liked_by?(user)` param. (b) Ruby 3.1 (correct). (c) got the symbol-literal vs keyword-label distinction cold (colon-left = value, colon-right = param name); sharpened only the "why has_many uses a symbol" (open-ended name = data → symbol; known config switch → keyword). Wrote concepts/keyword-argument-shorthand.md. Marked ✓ — first cold pass since 0.5. |
| 2026-08-23 | 0 | Gate 0.6: (a) poison value = `nil`/`false` — correct cold. (b) "a boolean" — right neighborhood but incomplete; didn't check that the three *memoized* methods all return Array/Integer (truthy, `0` included), so NONE hit the trap, and the boolean methods that could (`started?`/`completed?`) are deliberately unmemoized. Closed the gap through discussion + writing two LinkedIn posts (`!!0 => true`, false-never-caches). Wrote concepts/or-equals-memoization.md. Marked ~ (cold attempt partial; concept now ✓). |
| 2026-08-04 | 0 | Gate 0.5: first gate passed cold on the written attempt. (a) block fires on a missing key, (b) once across three same-key lookups because `hash[c] =` stores it, (c) dropping the assignment turns the cache into a factory — right direction, sharpened to the concrete consequence (new object every call, inner caches lost). Ran the object_id/size repro, all four matched. Wrote concepts/hash-default-block.md. Marked ✓. |
| 2026-07-26 | 0 | Gate 0.4: (a)/(b) cold — include puts module after class, prepend before, first match in `ancestors` wins. (c) had the right tools (owner, source_location) but wrong handle — must grab `obj.method(:x)`/`Class.instance_method(:x)` first, not call the method. Wrote concepts/method-lookup-and-reflection.md. Marked ~. |
| 2026-07-26 | 0 | Gate 0.3: extend half of the rule was fuzzy; called `.ancestors` a list of methods (it's modules). Ran the irb repro — seeing `Concernish` sit 2nd in `singleton_class.ancestors` made it click: extend = insert into singleton chain, which is why `included` resolves. Wrote concepts/include-vs-extend.md. Marked ~. |
| 2026-07-26 | 0 | Gate 0.2: receiver pairing right (has_many→class, liked_by? body→record). Missed *why* bare `has_many` fails — it's a load-time NoMethodError on the bare module, not misattachment. Sharpened concepts/included-do-and-self.md (corrected my own "wrong thing" imprecision). Marked ~. |
| 2026-07-26 | 0 | Gate 0.1: `return` proc-vs-lambda and `yield`/no-block both solid (named guard `has_block?`, actually `block_given?`). `self` inside `included do` missed — said "instance", it's the including class. Wrote concepts/included-do-and-self.md. Marked ~. |
