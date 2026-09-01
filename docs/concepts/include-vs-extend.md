# `include` vs `extend`, and the singleton ancestry

**The rule** — `include M` adds M's methods as **instance methods** of the includer
(callable on `Project.new`, i.e. on records). `extend M` adds M's methods as
**singleton methods** of the object doing the extending (callable *on that object
itself* — for a class or module, that's a class-level method). Same mixin, two
different destinations: the instance side vs. the singleton side.

**The identity that explains the destination** — `extend M` is exactly
`obj.singleton_class.include(M)`. `extend` is not a separate mechanism from `include`; it
is `include` aimed one level up, at the singleton class. That is why extended methods land
in `singleton_class.ancestors` and read as class-level: they are *instance* methods of the
singleton class, and a class is the sole instance of its own singleton. So the whole rule
collapses to one fact — `include` adds instance methods; `extend` adds instance methods to
the singleton, which you then call on the object itself.

**Where it shows up** — `app/models/concerns/likeable.rb:2`:

```ruby
extend ActiveSupport::Concern
```

- Models do `include Likeable` → they get `liked_by?` / `like` / `unlike` as
  **instance** methods (`some_project.liked_by?(user)`).
- `Likeable` does `extend ActiveSupport::Concern` → `Concern`'s methods (`included`,
  `class_methods`, …) become callable **on `Likeable` itself**.

**The proof, watched live in irb.** A minimal reproduction of line 2:

```ruby
module Concernish; def included_hook; end; end
module Likeableish; extend Concernish; end
Likeableish.singleton_class.ancestors
# => [#<Class:Likeableish>, Concernish, Module, Object, …, Kernel, BasicObject]
```

Two things this printout settles:

1. `.ancestors` returns a list of **modules/classes, never methods** — I first guessed
   it "contains all the methods of Concern"; it doesn't. It contains the *module*
   `Concernish` as a lookup-chain entry.
2. `Concernish` sits **second, right after the singleton class and before `Module`**.
   That position is the mechanism: calling `Likeableish.included_hook` walks the chain
   top-down, finds the method on `Concernish`, stops. `extend` = "insert into the
   *singleton* ancestry."

`Module`, `Object`, `Kernel`, `BasicObject` trail it because `Likeableish` is an
*instance of `Module`*, so its singleton ancestry inherits `Module`'s chain. (Real irb
may also show `JSON::GeneratorMethods` / `PP::ObjectMixin` — libraries that reopened
`Object`; noise.)

**Why this makes `included do` work.** `included` is an *instance method defined on
`ActiveSupport::Concern`*. Because `extend ActiveSupport::Concern` drops `Concern` into
`Likeable`'s singleton ancestry, the hook call `Likeable.included(base)` — fired when a
model does `include Likeable` — resolves through that chain to Concern's implementation,
which re-runs the stashed block against the model. See [[included-do-and-self]] for what
`self` is inside that block.
