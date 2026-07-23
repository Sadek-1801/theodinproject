#!/usr/bin/env ruby
# frozen_string_literal: true

# Verifies that every code citation in docs/ resolves to a real file and a real line.
#
# Citation forms (see docs/README.md):
#   `app/models/user.rb:23`                     -> this repo
#   `rwr:chatwoot app/models/account.rb:40`     -> a repo in real-world-rails
#
# Usage: ruby docs/bin/verify_citations.rb [path ...]
#        exits 0 when all citations resolve, 1 otherwise.

REPO_ROOT = File.expand_path('../..', __dir__)
RWR_ROOT  = File.expand_path('~/projects/rails-study/real-world-rails/apps')

CITATION = %r{
  `                                        # opening backtick
  (?:rwr:(?<app>[a-z0-9_.-]+)\s+)?         # optional picked-repo prefix
  (?<path>(?:app|lib|db|spec|config|bin)/[\w./-]+\.(?:rb|sql|erb|yml|yaml|js|json))
  :(?<line>\d+)                            # line number
  `                                        # closing backtick
}x

targets = ARGV.empty? ? Dir.glob(File.join(REPO_ROOT, 'docs', '**', '*.md')) : ARGV
failures = []
checked = 0

targets.sort.each do |doc|
  File.readlines(doc).each_with_index do |text, idx|
    text.scan(CITATION) do
      m = Regexp.last_match
      checked += 1
      where = "#{doc.sub("#{REPO_ROOT}/", '')}:#{idx + 1}"

      if m[:app] && !Dir.exist?(File.join(RWR_ROOT, m[:app]))
        failures << "#{where}  unknown picked repo: rwr:#{m[:app]}"
        next
      end

      base = m[:app] ? File.join(RWR_ROOT, m[:app]) : REPO_ROOT
      full = File.join(base, m[:path])

      unless File.file?(full)
        failures << "#{where}  missing file: #{m[:app] ? "rwr:#{m[:app]} " : ''}#{m[:path]}"
        next
      end

      total = File.foreach(full).count
      if m[:line].to_i > total
        failures << "#{where}  #{m[:path]}:#{m[:line]} out of range (file has #{total} lines)"
      end
    end
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
