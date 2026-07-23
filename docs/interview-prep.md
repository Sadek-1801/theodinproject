# Interview prep

**Technical only.** The non-technical half — networking, resume, applying, rates,
contracts — is in [`job-search.md`](job-search.md), because it is used at a different
time and by a different mechanism.

## Tradeoff talking points

The shape of a senior answer is *"chose X over Y because Z, and here is what it cost."*
Not a definition. Interviewers can read definitions.

Fill these from real decisions — ones made in the starter kit, or ones found and
understood in this codebase. A talking point without a specific instance behind it
collapses under one follow-up question.

| Decision | Chose | Over | Because | What it cost |
|---|---|---|---|---|
| Counting associated rows | `counter_cache` column | `COUNT(*)` per request | The parent page renders the count on every load and users is the largest table | Backfill on every existing row, and silent drift when anything writes around ActiveRecord (`app/models/user.rb:23`) |
| | | | | |

## Drill questions

Answered **out loud, no files open.** That constraint is the whole exercise — an answer
you can only produce while reading is not an answer you have.

Source these from gates that failed, not from a list of common interview questions.
`~` rows in [`progress.md`](progress.md) are the queue.

| Question | Source gate | Last drilled | Fluent? |
|---|---|---|---|
| | | | |

## Known weak spots

Honest list. The purpose is to *not discover these live in an interview* — and, second,
to have a good answer ready for "what don't you know yet", which is a question worth
preparing rather than improvising.

This list should never be empty. An empty weak-spot list means it is not being kept
honestly, not that there are no weak spots.

| Area | How weak | Plan | Reassessed |
|---|---|---|---|
| | | | |

### Standing, known at the outset

These are structural — known before any gate was attempted, from the shape of the
experience so far:

- **Production incident experience.** No on-call history, no debugging a live outage.
  Stage 14 addresses the reading-unfamiliar-code half; the incident half cannot be
  simulated and is worth saying plainly rather than talking around.
- **Rails at scale.** Everything studied here is a single-app, single-database shape.
  No sharding, no read replicas, no multi-region.
- **Rails 8 defaults are newer than the last hands-on Rails work** — Solid
  Queue/Cache/Cable, Propshaft, Kamal. Being explicit that these postdate the earlier
  learning is more credible than half-claiming them.
