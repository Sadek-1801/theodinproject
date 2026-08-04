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
