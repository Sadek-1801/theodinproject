# Concepts

One file per concept, in my own words. Written when a gate fails, or when something
clicks that did not before. Named after the concept in kebab-case: `counter-cache.md`,
`inverse-of.md`, `n-plus-one.md`.

**Revise these files; do not append to them.** A concept file is a current best
understanding, not a log. If a later stage shows the explanation was wrong, rewrite it
— the wrongness is recorded in `progress.md` and `interview-prep.md`, not here.

## Required in every file

- **A citation**, with the line quoted, not only referenced. A file without one is
  unfinished. See [`../README.md`](../README.md#citing-code).
- **Plain language.** If it reads like the Rails Guides, it is copied, not understood.
  The test: could you say this out loud to another developer without reading it?
- **The gotcha.** What actually bites people. If there isn't one, the concept was
  probably too small to deserve a file.

## Encouraged

- **An Ember contrast**, where one genuinely helps. Twenty shipped Ember projects is a
  large amount of transferable structure, and naming the analogy — or naming precisely
  where it breaks down — is faster than building the idea from scratch. Do not force
  it; a bad analogy costs more than none.

## Template

See [`counter-cache.md`](counter-cache.md) for a worked example.

```markdown
# <concept>

**What it is** — two or three sentences.

**Where it shows up** — the citation, with the line quoted.

**Why it's used here** — the actual reason this codebase reached for it.

**Gotcha** — what bites.

**Ember contrast** — optional.
```
