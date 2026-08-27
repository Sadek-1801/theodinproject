# `included do` and what `self` is inside it

**What it is** — `ActiveSupport::Concern` gives a module an `included do … end` hook.
The `do…end` is an ordinary **block**; the Concern stashes it and re-runs it *later*,
at the moment a class does `include ThisModule`, with `self` bound to **that including
class** (the class object, e.g. `Project`) — not to the module, and not to an instance.

**Where it shows up** — `app/models/concerns/likeable.rb:4`:

```ruby
included do
```

The two lines inside it are **class-level macros** — they configure the class:

```ruby
has_many :likes, as: :likeable, dependent: :destroy
attribute :liked, :boolean, default: false
```

For `has_many` to work, its receiver must be the class. So when the block runs, `self`
is `Project` / `Comment` / whichever model wrote `include Likeable`.

**Why bare-in-the-body actually fails (timing + receiver).** A line sitting loose in the
module body runs *immediately, at module-load time*, with `self` = `Likeable`, a plain
`Module`. `has_many` isn't a method plain modules have — it's defined in
`ActiveRecord::Associations::ClassMethods`, mixed into models, not into bare modules. So
`Likeable.has_many` raises `NoMethodError: undefined method 'has_many' for Likeable:Module`.
It does **not** misattach — it never gets that far. `included do` defers the code to
`include`-time, when `self` is the model, which *does* respond to `has_many`.

One-line version: `included do` means *"run this later, against the model — not now,
against the module."*

**The mechanism underneath** — `extend ActiveSupport::Concern` (`app/models/concerns/likeable.rb:2`):

```ruby
extend ActiveSupport::Concern
```

is what makes `included do` legal. Desugared, the hook is roughly:

```ruby
def self.included(base)   # base = the including class, handed in by Ruby
  base.class_eval do      # reopen that class; self and the default definee become it
    has_many :likes, ...
  end
end
```

`include Likeable` *calls* `Likeable.included(Comment)` immediately, mid-class-body —
`self` inside `included` is the module (it's a method on the module), and `base` is the
including class (Ruby passes it in). `class_eval` then re-runs the block with `self`
rebound to `base`, which is the entire reason the class macro lands on the model.
`included do … end` is sugar over exactly this `self.included(base)` + `base.class_eval`
shape.

**Contrast — instance method.** `app/models/concerns/likeable.rb:9`:

```ruby
def liked_by?(user)
```

A bare `def` in the module body becomes an **instance** method. When it runs, `self` is
the individual record (`a_project`), not the class.

**The test that catches it every time** — ask *"class method or instance method?"*
`has_many`, `attribute`, `validates`, `belongs_to` are class macros → they need `self`
to be a **class** → they belong inside `included do`. A plain `def` is an instance
method → `self` is the **record** → it goes in the module body.

**My earlier mistakes** — I first said `self` was "an instance." Wrong twice over:
it's the *class*, and a block has no "instances" anyway — the only question is what
`self` is bound to while the block runs.

**The anchor that kills the "instance" answer — the clock.** `included do` runs at
**load time**, the instant the class body hits `include Likeable`. At that moment the
only objects in existence are the module and the class — no `Comment.new` has run, no
record has been born. So `self` *cannot* be an instance: there is no instance yet to be
one. Instances belong to a different clock — **run time**, once per call per record —
which is where `self.liked = true` (`app/models/concerns/likeable.rb:26`) lives:

```ruby
self.liked = true
```

One file, two clocks. Which `self` you get is decided entirely by which block, on which
clock — not by anything you can read off the line in isolation.

**Unrelated slip, parked here so it sticks** — the guard for `yield` with no block is
`block_given?`, **not** `has_block?` (which does not exist):

```ruby
def foo
  yield if block_given?
end
```
