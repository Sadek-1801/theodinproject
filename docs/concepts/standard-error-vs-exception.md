# `StandardError` vs `Exception`, and `rescue_from` vs `rescue`

**The hierarchy and where the line is drawn.** `Exception` is the root of *everything*
raisable. `StandardError` is one branch under it — the "ordinary, recoverable" errors. A
bare `rescue` (no class named) catches **`StandardError` and its descendants only**, not
all of `Exception`. That is deliberate: it lets a generic handler grab the errors you can
reasonably recover from while leaving the dangerous ones alone.

**What lives *above* `StandardError` (sibling branches under `Exception`) — the ones a
generic rescue must NOT swallow:**

- `SignalException` / `Interrupt` — OS signals, including **Ctrl-C**.
- `NoMemoryError` — out of memory (nothing left to recover *with*).
- `SystemExit` — raised by `exit`; the program *choosing* to quit.
- `ScriptError` (→ `LoadError`, `SyntaxError`) — load/parse failures.

These aren't all "system" faults in a hardware sense (`SystemExit` is a deliberate quit,
`ScriptError` is a load problem) — the unifying idea is *"conditions a handler shouldn't
eat."* Ruby encodes that by placing them under `Exception` but **outside** `StandardError`.

**Why `rescue Exception` is a bug.** It reaches up and grabs those siblings too. Concrete
consequences:

- Catch `Interrupt` → **Ctrl-C stops working**; you lose the normal way to kill the
  process.
- Catch `SystemExit` → an `exit` inside the block is silently eaten; the program won't
  quit when told to.
- Catch `NoMemoryError` → you "handle" a situation where there's nothing left to handle
  with.

A bare `rescue` (i.e. `rescue => e`) already catches everything you *should*; naming
`Exception` only adds the things you shouldn't.

**`rescue` vs `rescue_from` — NOT the same mechanism.** Two independent axes:

1. **What kind of thing.** `rescue` is a **language keyword**, baked into Ruby syntax. It
   exists only attached to a `begin`/`end` (or method) body, and it fires *inline, the
   instant* an exception flies through **that specific block**.
   `rescue_from` is a plain **method call** — provided by **`ActiveSupport::Rescuable`**
   (mixed into `AbstractController` / `ActionController::Base`). *(The `ActiveRecord`
   part of the line is the exception being caught, not the source of `rescue_from`.)*

2. **When it runs.** `rescue` is evaluated *as the code runs*. `rescue_from` runs **once,
   at class-load time**, and all it does then is **register** a handler in a list — it
   catches nothing at that moment. Later, *at request time*, ActiveSupport wraps each
   controller action; if an exception escapes, it walks the registered list for a match.

**Where it shows up** — `app/controllers/application_controller.rb:10`:

```ruby
rescue_from ActiveRecord::RecordNotFound, with: :not_found_error
```

Read it as: *"for the whole controller (and subclasses), when a `RecordNotFound` escapes
any action, call `not_found_error`."* The handler, `app/controllers/application_controller.rb:20`:

```ruby
def not_found_error
```

renders a 404 page. This is controller-*wide* and declarative — one registration covers
every action — which a local `begin/rescue` around a single method could never do without
repetition.

**My earlier mistakes.** (a) I knew the shape but didn't *name* the above-`StandardError`
errors — vague "system error" instead of `Interrupt`/`SystemExit`/`NoMemoryError`/
`ScriptError`. (c) two real slips: I attributed `rescue_from` to **ActiveRecord** (it's
**ActiveSupport::Rescuable** — ActiveRecord only supplies the *exception* argument), and
I called `rescue` a "method-level catcher" when it's a **keyword** tied to a block,
missing the register-at-load-time vs. catch-inline timing distinction. I had the *scope*
difference (controller-wide vs. local) right.

One line to remember: **bare `rescue` = `StandardError` (recoverable) — never `rescue
Exception` (grabs Ctrl-C, exit, OOM). `rescue` is a keyword that catches inline;
`rescue_from` is an ActiveSupport method that registers a controller-wide handler at load
time and catches at request time.**

See [[or-equals-memoization]] and [[keyword-argument-shorthand]] for the other Stage 0
idioms in this file set.
