# Reference repos

Seeing a pattern in one codebase teaches that codebase's version of it — you cannot
separate the concept from local taste. Seeing it in two or three forces the
abstraction, which is the point if the goal is walking into unfamiliar client code.

Past three repos this becomes a research project rather than learning. Hence: this repo
as the primary specimen, three hand-picked apps as deliberate second exposures, and the
remaining ~215 as an on-demand reference library.

Second exposures are also naturally **spaced** — meeting `has_many :through` again in
chatwoot weeks after meeting it here is spaced repetition, which beats massed study.

## Primary specimen — this repo

Rails 8.1, actively maintained, and unusually disciplined: the largest model is 87
lines (`app/models/user.rb:1`), services are under 45 lines, and there are 163 spec
files. Real production hygiene — Sentry, rack-attack, Flipper, sidekiq-cron, VCR,
cuprite.

**What it cannot teach:** the domain is small. A 396-line schema, essentially no API
surface, no money, no multi-tenancy, two ActiveRecord callbacks in 23 models. Those
absences are exactly what the picks below cover — and several of them are worth
noticing as findings in their own right rather than treated only as gaps.

## The picks

### chatwoot — stages 6, 10

**What it is:** open-source customer support platform. Large, actively developed,
commercially backed.

**Serves:** account-scoped multi-tenancy and a real versioned API — the two biggest
structural gaps here. It is also the closest shape to a typical freelance SaaS build,
which makes it the most directly transferable of the three.

**Read:** the `Account` model and how every query is scoped through it; the
`app/controllers/api/v1/` and `v2/` split and what changed between versions; the
serializer layer.

**Not good for:** reading end to end. It is far too large. Use it for targeted
comparison against a specific pattern you have already met here.

### gumroad — stages 11, 1

**What it is:** the creator-commerce platform, open-sourced in 2025. 424 MB.

**Serves:** real payments, payouts, refunds, and money modeling in production —
integer cents, currency handling, invoicing, the reconciliation edge cases. Nothing in
this repo touches money at all.

**Read:** how money columns are typed and constrained in the schema (worth revisiting
stage 1's constraint gates against it), the Stripe integration boundary, and webhook
idempotency handling.

**Not good for:** style. It is an old, large, commercially-pressured codebase and
reads like one. That is itself instructive — but do not mistake it for a model to
imitate.

### lobsters — stage 14, and not before

**What it is:** the link-aggregator running lobste.rs. 8.3 MB — small enough to read
end to end, which is the entire reason it is here.

**Serves:** whole-codebase comprehension. Reading an application in its entirety is a
distinct skill from reading a file, and it is the one that decides how fast you can be
useful on unfamiliar client code.

**Adopted at stage 14 deliberately.** It serves one purpose and would be a distraction
earlier.

**Not good for:** modern patterns. It is deliberately conservative and old-fashioned
Rails — which is, again, representative of what freelance work actually looks like.

## Deliberately not picked

- **mastodon** — excellent for APIs and jobs at scale, but overlaps chatwoot's role.
  Standing candidate if API-at-scale proves undercovered by stage 14.
- **discourse**, **canvas-lms** — too large to read. `grep` targets only.
- **spree**, **solidus** — commerce, but Rails engine architecture is a detour from
  everything else here.

## Using the wider corpus

The remaining ~215 apps are a reference library, not a curriculum. Query them when a
specific question arises — "how do other people structure webhook handlers?" — never
as reading material.

Search with the `/real-world-rails` skill. **Note:**
`~/projects/rails-study/real-world-rails` is not on that skill's default search path
and must be named explicitly in the request.

Refresh submodules with `bin/update` in the `real-world-rails` checkout. Expect
picked-repo paths to drift over months — which is why citations quote the line as well
as numbering it.

## Citing a pick

`` `rwr:chatwoot app/models/account.rb:40` `` — the `rwr:` prefix plus the app
directory name, then the path within that app. `ruby docs/bin/verify_citations.rb`
resolves these against `~/projects/rails-study/real-world-rails/apps/`.
