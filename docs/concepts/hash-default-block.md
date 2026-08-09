# `Hash.new` with a default block — cache vs factory

**Three forms of `Hash.new`:**

```ruby
Hash.new                       # missing key → nil
Hash.new(0)                    # missing key → the SAME default object every time
Hash.new { |hash, key| ... }   # missing key → runs the block, fresh each time
```

The default (value or block) fires **only on a missing key** — a key the hash does not
currently hold. Not on creation, not on a key already present, never on `[]=` or `fetch`.
Plain `[]` lookup of an absent key is the only trigger.

**The block gets two arguments: the hash itself and the missing key.** Because it is
handed the hash, the block *can* store something under that key — but only if you write
the assignment. That single choice is the whole concept:

- **With `hash[key] = …` → cache.** Build once, store it, reuse it. The key is now
  present, so later lookups skip the block and return the stored object. `hash.size`
  grows.
- **Without the assignment → factory.** The block only *returns* a value; nothing is
  stored. The key stays missing forever, so *every* lookup re-runs the block and builds
  a brand-new object. `hash.size` stays `0`.

**Where it shows up** — `app/models/user.rb:45`:

```ruby
@progress ||= Hash.new { |hash, c| hash[c] = CourseProgress.new(c, self) }
```

This is a cache, deliberately: `hash[c] = CourseProgress.new(c, self)` stores one
`CourseProgress` per course. Three lookups of the same course run the block **once** —
the first miss builds and stores; lookups two and three find the key present and return
the stored object. The outer `@progress ||=` is a second layer of the same idea: it
memoizes the *hash itself* across calls to `progress_for` (see [[or-equals-memoization]]).

**Drop the `hash[c] =` and it silently becomes a factory.** `@progress[course]` would
still hand back a `CourseProgress`, so nothing crashes — but a *different* object every
call. Any state that object caches internally (e.g. `CourseProgress`'s own
`@lesson_ids ||= …`) is thrown away between calls, because it is a new object each time.
The bug is invisible until something depends on identity or on the inner cache holding.

**Proof in one irb session:**

```ruby
cache   = Hash.new { |h, k| h[k] = "built-#{k}" }
factory = Hash.new { |h, k|       "built-#{k}" }   # no assignment

cache[:a].object_id   == cache[:a].object_id     # => true   (same object, reused)
factory[:a].object_id == factory[:a].object_id   # => false  (new object each time)
cache.size    # => 1   (kept :a)
factory.size  # => 0   (kept nothing)
```

One line to remember: **the assignment is the difference between a cache and a factory.**
`hash[k] = …` makes the hash accumulate and reuse; drop it and the hash stays empty and
rebuilds.

---

## Wrote it up (LinkedIn)

Two posts drafted from this line. Post 1 is this file's concept (the inner default
block); Post 2 is the outer `||=` (see [[or-equals-memoization]]).

### Post 1 — "Why did they store it?"

> I was exploring theodinproject's github repo and one line in a model made me stop:
>
> ```ruby
> @progress ||= Hash.new { |hash, c| hash[c] = CourseProgress.new(c, self) }
> ```
>
> I was thinking, why did they write `hash[c] = CourseProgress.new(...)`?
> Why store it? They could have just written:
>
> ```ruby
> Hash.new { |_hash, c| CourseProgress.new(c, self) }
> ```
>
> Both return a `CourseProgress`. So what is the `=` doing there?
>
> First, `Hash.new` has three forms:
>
> ```ruby
> Hash.new            # missing key → nil
> Hash.new(0)         # missing key → the SAME default object
> Hash.new { |h, k| } # missing key → runs the block
> ```
>
> The block only runs when you look up a key that is missing. And the block gets the hash itself, so it *can* store something. Whether you store it is the whole point.
>
> ```ruby
> cache   = Hash.new { |h, k| h[k] = "built-#{k}" }  # stores
> factory = Hash.new { |h, k|       "built-#{k}" }   # doesn't
>
> cache[:a]
> cache[:a]      # block runs only ONCE, second time it finds it stored
> cache.size     # => 1
>
> factory[:a]
> factory[:a]    # block runs BOTH times, nothing kept
> factory.size   # => 0
> ```
>
> So that's the answer.
> -> With `hash[c] =` it becomes a cache. Build one `CourseProgress` per course, then reuse it.
> -> Without it, it becomes a factory. A new object every single lookup, and anything that object remembered inside is thrown away.
>
> The scary part is nothing breaks without the `=`. It just quietly does the same work again and again.
>
> One character is the difference between remembering and rebuilding.

### Post 2 — the `||=` sitting in front of it

> A follow up to my last post.
>
> That same line from theodinproject had one more thing I skipped over:
>
> ```ruby
> @progress ||= Hash.new { |hash, c| hash[c] = CourseProgress.new(c, self) }
> ```
>
> Last time I explained the `hash[c] =` part inside the block. But there is a second cache sitting in front of it: the `@progress ||=`. Two layers, two jobs.
>
> `x ||= expr` is just `x || (x = expr)`. The right side runs only when `x` is falsy.
>
> -> First call, `@progress` is nil (falsy), so the hash gets built.
> -> Every later call, `@progress` is already a hash (truthy), so it is skipped and reused.
>
> So the two layers are:
> -> `@progress ||=` builds the hash once per user
> -> `hash[c] =` builds one `CourseProgress` once per course
>
> Then I learned the trap. `||=` decides reuse vs recompute only by truthy or falsy. And Ruby has exactly two falsy values: `nil` and `false`. Nothing else.
>
> This surprised me coming from other languages:
>
> ```ruby
> !!0     # => true   (zero is TRUTHY in Ruby)
> !!""    # => true
> !![]    # => true
> !!nil   # => false
> !!false # => false
> ```
>
> Why it matters: if you memoize a value that is really `false`, `||=` cannot tell "I cached a real false" from "I never ran". So it runs again every time. No error, just wasted work.
>
> ```ruby
> def admin?
>   @is_admin ||= expensive_check  # if the answer is false, this NEVER caches
> end
> ```
>
> But a count that could be `0`? Totally safe to memoize, because `0` is truthy.
>
> `||=` is the memoization workhorse in Ruby. Just know exactly what it counts as "empty", or you will cache things that were never cached at all.
>
> *(Note: the `admin?` snippet is an illustration, not from the repo — the real `CourseProgress` only memoizes an Array and two counts, all truthy, so all safe.)*
