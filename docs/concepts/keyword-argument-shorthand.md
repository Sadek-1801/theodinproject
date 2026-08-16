# Keyword-argument value omission, and symbol vs keyword

**The shorthand.** Since **Ruby 3.1** you can omit the value in a hash literal or keyword
argument when a local variable (or method) of the *same name* is in scope: `{x:}` means
`{x: x}`, and `foo(x:)` means `foo(x: x)`. It is pure punning on the name — nothing more.

**Where it shows up** — `app/models/concerns/likeable.rb:10`:

```ruby
likes.exists?(user:)
```

expands to `likes.exists?(user: user)`. It only works because a local named `user` is in
scope — the method parameter one line up, `app/models/concerns/likeable.rb:9`:

```ruby
def liked_by?(user)
```

So `user:` (the keyword-argument label) is filled by the local `user`. Rename the
parameter and the shorthand breaks — there would be no matching name to pun on.

**Symbol vs keyword — same colon, opposite sides, two different features.** The trap is
that a colon appears in both. Position tells them apart. `app/models/concerns/likeable.rb:5`:

```ruby
has_many :likes, as: :likeable, dependent: :destroy
```

- **Colon on the left** (`:likes`, `:likeable`, `:destroy`) → a **Symbol literal**. A
  lightweight, immutable, interned label — a *value* you pass as data.
- **Colon on the right** (`as:`, `dependent:`) → a **keyword-argument label**. Part of
  the call syntax, naming *which parameter* the following value fills.

So one line carries both: `as:`/`dependent:` are argument labels; their *values* happen
to be the symbols `:likeable`/`:destroy`; and `:likes` is a positional symbol argument.

**Why `has_many` takes the name as a symbol, not a keyword.** `:likes` is the *thing
being named* — the association's open-ended identity, data the macro stores and operates
on. There is no fixed parameter called `likes`. Whereas `as:` and `dependent:` are a
*known menu* of configuration switches the method defines ahead of time — exactly what
keyword arguments are for. Rule of thumb: **open-ended name/identity → symbol value;
known configuration switch → keyword arg.**

**Proof in one irb session:**

```ruby
def show(user:) = user
name = "ada"
show(name:)           # => "ada"   (name: name, punned from the local)
show()                # ArgumentError: missing keyword: :user  (no local to pun)

:likes.class          # => Symbol   (colon-left is a value)
:likes.frozen?        # => true     (interned/immutable)
```

One line to remember: **colon-left is a value (Symbol); colon-right is a parameter name
(keyword). The 3.1 shorthand `foo(x:)` just drops a value that matches a local's name.**
