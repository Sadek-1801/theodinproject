# Method lookup: `include` vs `prepend`, and how to interrogate a winner

**Lookup order = `ancestors`, top-down, first match wins.** The only question `include`
vs `prepend` settles is *where the module lands in that array relative to the class*:

- `include M` → module goes **after** the class: `[Project, Likeable, …]`. The class's
  own method wins; the module is a fallback.
- `prepend M` → module goes **before** the class: `[Likeable, Project, …]`. The module's
  method wins and can wrap the class's (via `super`).

**Where it shows up** — a model gets `liked_by?` from the concern at
`app/models/concerns/likeable.rb:9`:

```ruby
def liked_by?(user)
```

If that model *also* defined its own `liked_by?`, `include Likeable` means the model's
wins; `prepend Likeable` means the concern's wins.

**Interrogating the winner without editing either file (the gap I hit).** You cannot
read `.owner` off a *call* — `project.liked_by?(user)` runs the method and returns its
result, not a handle. You first grab a **Method object by symbol**, then inspect it:

```ruby
project.method(:liked_by?)            # Method (bound to an instance)
Project.instance_method(:liked_by?)   # UnboundMethod (from the class)

Project.instance_method(:liked_by?).owner            # which module/class actually defines the winner
Project.instance_method(:liked_by?).source_location  # => ["…/likeable.rb", 9]
```

`ancestors` shows the whole chain; **`.owner` names the single link that won**;
`.source_location` points at the exact file+line. The trap is reflexively writing
`obj.method_name.owner` — that calls the method. It's `obj.method(:method_name).owner`.

**`.owner` is the defining module, not the class you called on.** `comment.method(:liked_by?).owner`
returns `Likeable`, not `Comment` — even though you asked a `Comment`. `owner` cuts straight
through the ancestor chain to the link that actually holds the `def`. That's the point of it:
the receiver's class tells you *who you asked*, `owner` tells you *who answered*.

**Proof in one irb session — `.owner` flips with the verb:**

```ruby
module M; def who; :module; end; end
class Inc; include M; def who; :own; end; end
class Pre; prepend M; def who; :own; end; end

Inc.new.who                      # => :own      (class wins)
Pre.new.who                      # => :module   (module wins)
Inc.instance_method(:who).owner  # => Inc
Pre.instance_method(:who).owner  # => M
```

See [[include-vs-extend]] for why `ancestors` is the lookup chain in the first place.
