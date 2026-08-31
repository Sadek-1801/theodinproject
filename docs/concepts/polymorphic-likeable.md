# Polymorphic `has_many … as:` — one table, many owners

**The problem it solves.** Comments can be liked. Posts can be liked. You do *not* want a
separate `comment_likes` table and `post_likes` table. You want one `likes` table that
can belong to any of them. That is what a polymorphic association buys you.

**The parent side** — `app/models/concerns/likeable.rb:5`:

```ruby
has_many :likes, as: :likeable, dependent: :destroy
```

`as: :likeable` says: "the `Like` on the other end points back to me through an interface
named `likeable`, not through a fixed `comment_id` column." The name `likeable` is the
hinge — it appears in three places and that shared word is what wires them together:

- `Likeable` — the shared module (the concern)
- `as: :likeable` — this line
- `belongs_to :likeable` — the child side

**The child side** — `app/models/like.rb:3`:

```ruby
belongs_to :likeable, polymorphic: true, counter_cache: true
```

`polymorphic: true` is the matching half. It tells `Like` that its owner is not one fixed
model — it is whatever model included `Likeable`.

**How one table serves many owners** — the interface is *two* columns, not one.
`db/schema.rb:229` — *which* record was liked (e.g. `42`):

```ruby
t.integer "likeable_id", null: false
```

`db/schema.rb:230` — *which model* it was (`"Comment"`, `"Post"`):

```ruby
t.string "likeable_type", null: false
```

Together they name one exact record. A like on comment 42 stores
`likeable_id: 42, likeable_type: "Comment"`. A like on post 7 stores
`likeable_id: 7, likeable_type: "Post"`. Both rows live in the same `likes` table. Add a
new likeable model tomorrow and it drops in for free — no new table, no new column. It
just becomes another value in `likeable_type`.

**Why it lives in a concern.** The payoff is: any model that writes `include Likeable`
instantly becomes a valid `likeable_type`. The polymorphic association and the concern
are the same idea from two angles — "this behavior is shared across many models" — which
is exactly why the like/unlike code is a mixin and not a method on one model.

**`dependent: :destroy`.** When a comment is deleted, delete its likes too. Rails loads
each `Like` and calls `.destroy` on it one at a time, so callbacks and the counter cache
stay correct, and no like row is left pointing at a comment that no longer exists.
Contrast `dependent: :delete_all` (one bulk SQL `DELETE`, skips callbacks).

**Link.** The reason `has_many :likes` can even sit on `Comment`/`Post` in the first
place is [[included-do-and-self]] — it runs inside `included do`, where `self` is the
including class, which is the only receiver `has_many` responds to.
