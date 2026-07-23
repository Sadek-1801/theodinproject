# counter_cache

**What it is** — a denormalised integer column on the *child's* parent table holding
the number of associated rows, maintained by ActiveRecord on create and destroy so
`parent.children.count` becomes a column read instead of a `COUNT(*)`.

**Where it shows up** — `app/models/user.rb:23`:

```ruby
belongs_to :path, optional: true, counter_cache: true
```

The option goes on the `belongs_to` side, which reads backwards at first: the *user*
declares it, but the column `users_count` lives on `paths`. Rails needs the
declaration where the write happens, and the write happens when a user is created.

Also at `app/models/like.rb:3`, combined with polymorphism:

```ruby
belongs_to :likeable, polymorphic: true, counter_cache: true
```

Here the counter column has to exist on *every* table that can be `likeable` — the
association does not know which class it will point at until runtime.

**Why it's used here** — path pages render the number of users on each path. Without
the cache that is a `COUNT(*)` over the users table on every page load, and users is
the largest table in the app.

**Gotcha** — **adding it to a table with existing rows leaves every counter at zero
or NULL.** Rails only maintains the counter from the moment the association writes;
it does not backfill. The migration is two steps, not one:

```ruby
add_column :paths, :users_count, :integer, default: 0, null: false
# then, in a separate step:
Path.find_each { |path| Path.reset_counters(path.id, :users) }
```

Second gotcha: `update_column`-style writes and raw SQL bypass it, so the counter
drifts silently. There is no error — just a wrong number on a page. `reset_counters`
is the repair.

**Ember contrast** — closest thing is a computed property with a cached dependent key,
except the cache lives in Postgres rather than in memory, survives the request, and
has no invalidation mechanism watching it. Ember's tracking would notice the
dependency changed; Postgres will not. That missing invalidation is the entire
gotcha above.
