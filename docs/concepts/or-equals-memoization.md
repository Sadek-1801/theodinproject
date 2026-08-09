# `||=` memoization and the falsy trap

**What `||=` is.** `x ||= expr` expands to `x || (x = expr)`. The right side runs **only
when the stored `x` is falsy**. Used on an instance variable, that is memoization: an
unset `@foo` is `nil` (falsy), so the first call computes and stores; every later call
sees a truthy value and skips the work.

**The trap — `||=` judges "reuse vs recompute" purely by truthy/falsy, and Ruby has
exactly two falsy values: `nil` and `false`.** Nothing else. So if the memoized result
is *legitimately* `nil` or `false`, `||=` cannot tell "I cached that falsy answer" from
"I never ran" — it silently recomputes on every call. `false` is the classic bite: you
meant to cache a real "no", but it is thrown away each time. No error, just wasted work.

The surprise coming from other languages: **`0`, `""`, `[]` are all truthy in Ruby.**
Only `nil` and `false` are falsy. So memoizing an Integer count that could be `0`, or an
Array that could be empty, is perfectly safe.

**Where it shows up** — `app/services/course_progress.rb:24`:

```ruby
@lesson_ids ||= course.lesson_ids
```

This file memoizes three times, and the gate is whether any of them hit the trap. They
do not — every memoized value is truthy:

- `lesson_ids` (line 24) → an **Array**. Always truthy, even when empty.
- `total_lessons` (line 28) → an **Integer** (`lesson_ids.size`). Truthy even at `0`.
- `completed_lessons` (line 32) → an **Integer** DB count. Truthy even at `0`.

```ruby
@completed_lessons ||= user.lesson_completions.where(lesson_id: lesson_ids).size
```

The methods that *could* return `false` are the boolean ones — and they are
**deliberately not memoized**. `app/services/course_progress.rb:8`:

```ruby
completed_lessons.positive?
```

That is the payoff of the trap: if someone "optimized" `started?` to
`@started ||= completed_lessons.positive?`, then for a course the user has not started
(`positive?` → `false`), the memo would never take, and the whole `completed_lessons`
query would re-run on every call. Leaving `started?` unmemoized is the correct call.

**Why memoize at all** — the two truthy values are the results of **DB work**
(`course.lesson_ids`; the `lesson_completions.where(...)` count). `started?`,
`completed?`, and `percentage` each read them, so one rendered progress bar would fire
the same queries several times over. `||=` runs each query once per object and reuses
it. That only pays off because the outer `@progress ||= Hash.new { … }` in
`app/models/user.rb:45` keeps the *same* `CourseProgress` object alive across calls — see
[[hash-default-block]] for how a factory there would throw these inner caches away.

**Proof in one irb session:**

```ruby
!!0     # => true    (zero is TRUTHY in Ruby)
!!""    # => true
!![]    # => true
!!nil   # => false
!!false # => false

# the false-caching trap, watched live:
$calls = 0
def admin?
  @is_admin ||= ($calls += 1; false)   # answer is a legit false
end
admin?; admin?; admin?
$calls  # => 3   (never cached — recomputed every call)
```

Swap that `false` for any truthy value (`0`, `[]`, `"x"`) and `$calls` stops at `1`.

**My earlier mistakes** — asked which *memoized* methods could hit the falsy trap, I
answered "a boolean." Right neighborhood (booleans are where `false` lives), wrong
target: I never checked the return types of the three methods that are *actually*
memoized. All three are Array/Integer → truthy → **none** hit the trap. The boolean
methods that would are the ones left unmemoized. The lesson: to answer "does `||=` bite
here?", read the *memoized* value's type, not the vibe of the surrounding file.

One line to remember: **`||=` treats only `nil` and `false` as "not cached yet" — so
memoize truthy results freely, and never memoize a value whose real answer can be
`false`.**
