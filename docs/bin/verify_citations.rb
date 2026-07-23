#!/usr/bin/env ruby
# frozen_string_literal: true

# Verifies that every code citation in docs/ resolves to a real file, a real line,
# and (when the citation immediately precedes a fenced code block) that the block
# quotes that line correctly.
#
# Citation forms (see docs/README.md):
#   `app/models/user.rb:23`                     -> this repo
#   `rwr:chatwoot app/models/account.rb:40`     -> a repo in real-world-rails
#
# Detection is two-stage:
#   - Loose pass:  anything that *looks like* a citation attempt — a backtick-
#                  delimited span containing a `/` and ending in `:<digits>`.
#   - Strict pass: the span must additionally match the real grammar (optional
#                  `rwr:<app> ` prefix, a path ending in a recognised code-file
#                  extension, then `:<digits>`).
# A span that passes loose but fails strict is reported as a failure ("unrecognized
# citation form") rather than silently ignored — malformed citations must never
# disappear from the count.
#
# Usage: ruby docs/bin/verify_citations.rb [path ...]
#        exits 0 when all citations resolve (and quotes match), 1 otherwise.
#
# The default (no-argument) scan excludes docs/superpowers/ — that directory holds
# the process documents (design spec, implementation plan), authored once, which
# describe citations — including deliberately broken ones — as worked examples
# rather than living claims about the codebase. The learning notes under docs/
# proper are the living documents this tool exists to guard against citation rot.
# This is a default only: an explicit path argument still checks anything given,
# docs/superpowers/ included.
#
# Known limitation: scoped quote-checking (below) is line-based and does not track
# fence nesting, so a citation-plus-fence pair embedded inside an *outer* fence of
# the same delimiter (e.g. a worked example shown inside a ```markdown block) is
# not reached — the inner ``` is read as closing the outer fence, per how a plain
# per-line toggle (and most simple parsers) resolve same-delimiter nested fences.
# Flat, top-level citation-plus-fence pairs are unaffected.

REPO_ROOT = File.expand_path('../..', __dir__)
RWR_ROOT  = File.expand_path('~/projects/rails-study/real-world-rails/apps')

# Anything backtick-delimited that looks like it is trying to be a citation.
LOOSE_CITATION = %r{
  `                                        # opening backtick
  (?<body>[^`\n]*/[^`\n]*:\d+)             # contains a slash, ends in :<digits>
  `                                        # closing backtick
}x

CODE_EXTENSIONS = %w[rb sql erb yml yaml js jsx ts tsx json rake ru haml slim].freeze

# The real grammar. Matched against the *whole* body captured by LOOSE_CITATION
# (anchored \A...\z) — no path-prefix allowlist, any path shape is acceptable;
# whether it is real is settled by the file-existence check below.
STRICT_CITATION = %r{
  \A
  (?:rwr:(?<app>[a-z0-9_.-]+)\s+)?          # optional picked-repo prefix
  (?<path>[\w./-]+\.(?:#{CODE_EXTENSIONS.join('|')}))
  :(?<line>\d+)
  \z
}x

FENCE_MARKER = /\A```/.freeze

# Scans one line of text and returns every loose citation attempt found, each as
# { raw:, body:, strict: } where `strict` is the MatchData against
# STRICT_CITATION, or nil if the span does not match the real grammar.
# Spans containing "://" are skipped entirely (a URL with a port is not a citation).
def scan_citations(text)
  results = []
  text.scan(LOOSE_CITATION) do
    m = Regexp.last_match
    body = m[:body]
    next if body.include?('://')

    results << { raw: m[0], body: body, strict: STRICT_CITATION.match(body) }
  end
  results
end

# Resolves a strict citation MatchData to its absolute file path, or nil if the
# picked repo is unknown. Does not check existence.
def resolve_path(strict_match)
  app = strict_match[:app]
  return nil if app && !Dir.exist?(File.join(RWR_ROOT, app))

  base = app ? File.join(RWR_ROOT, app) : REPO_ROOT
  File.join(base, strict_match[:path])
end

def display_citation(strict_match)
  app = strict_match[:app]
  "#{app ? "rwr:#{app} " : ''}#{strict_match[:path]}:#{strict_match[:line]}"
end

# Compares the first non-empty line inside a fence against the cited line of the
# cited file (both .strip'ped). Appends a failure on mismatch or unresolvable cite.
def check_quote(pending, actual_stripped, where, failures)
  strict = pending[:strict]
  app = strict[:app]
  return if app && !Dir.exist?(File.join(RWR_ROOT, app)) # already reported elsewhere

  full = resolve_path(strict)
  return unless full && File.file?(full) # missing-file already reported elsewhere

  line_no = strict[:line].to_i
  file_lines = File.readlines(full)
  return if line_no < 1 || line_no > file_lines.size # out-of-range already reported

  expected = file_lines[line_no - 1].strip
  return if expected == actual_stripped

  failures << "#{where}  quote mismatch for #{display_citation(strict)}: " \
              "doc says #{actual_stripped.inspect}, file has #{expected.inspect}"
end

EXCLUDED_DEFAULT_DIR = File.join(REPO_ROOT, 'docs', 'superpowers')

targets = if ARGV.empty?
            Dir.glob(File.join(REPO_ROOT, 'docs', '**', '*.md'))
               .reject { |f| f.start_with?("#{EXCLUDED_DEFAULT_DIR}/") }
          else
            ARGV
          end
failures = []
checked = 0

targets.sort.each do |doc|
  begin
    lines = File.readlines(doc)
  rescue Errno::ENOENT, Errno::EISDIR => e
    failures << "#{doc.sub("#{REPO_ROOT}/", '')}  cannot read: #{e.class}: #{e.message}"
    next
  end

  prev_nonblank = nil # { text:, where: } of the nearest preceding non-blank line
  in_fence = false
  pending = nil # citation to check against the fence we just entered
  awaiting_content = false # true until the first non-empty line inside the fence

  lines.each_with_index do |text, idx|
    where = "#{doc.sub("#{REPO_ROOT}/", '')}:#{idx + 1}"
    stripped = text.strip

    if stripped.match?(FENCE_MARKER)
      if in_fence
        in_fence = false
        awaiting_content = false
        pending = nil
      else
        in_fence = true
        awaiting_content = false
        if prev_nonblank
          last = scan_citations(prev_nonblank[:text]).last
          if last && last[:strict]
            pending = { strict: last[:strict] }
            awaiting_content = true
          end
        end
      end
    elsif in_fence && awaiting_content && !stripped.empty?
      check_quote(pending, stripped, where, failures)
      awaiting_content = false
    end

    scan_citations(text).each do |cite|
      checked += 1

      unless cite[:strict]
        failures << "#{where}  unrecognized citation form: #{cite[:raw]}"
        next
      end

      m = cite[:strict]
      if m[:app] && !Dir.exist?(File.join(RWR_ROOT, m[:app]))
        failures << "#{where}  unknown picked repo: rwr:#{m[:app]}"
        next
      end

      full = resolve_path(m)
      unless File.file?(full)
        failures << "#{where}  missing file: #{display_citation(m)}"
        next
      end

      total = File.foreach(full).count
      if m[:line].to_i > total
        failures << "#{where}  #{display_citation(m)} out of range (file has #{total} lines)"
      end
    end

    prev_nonblank = { text: text } unless stripped.empty?
  end
end

puts "checked #{checked} citation(s) across #{targets.size} file(s)"

if failures.empty?
  puts 'OK'
  exit 0
end

warn "\n#{failures.size} bad citation(s):"
failures.each { |f| warn "  #{f}" }
exit 1
