#!/usr/bin/env ruby

require 'rubygems'
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('1.9')
  $stderr.puts "This script requires Ruby >= 1.9"
  exit 1
end

require 'open3'
result = Open3.capture3('git rev-parse --show-toplevel')
unless result[2].exitstatus == 0
  $stderr.puts "You do not appear to be in a git repository. This script must be run from inside a git repository."
  exit 2
end
filename = result[0].lines.first.chomp + '/CHANGES.md'
unless File.exist?(filename)
  $stderr.puts "CHANGES.md not found. Please ensure that CHANGES.md exists."
  exit 3
end
contents = IO.read(filename)

lines = contents.lines.drop(3).map(&:chomp).reject(&:empty?)
versions = Hash.new
currentversion = nil
versions[nil] = []
lines.each_with_index do |line, index|
  if line =~ /\A-+\z/
    versions[currentversion].pop
    currentversion = lines[index-1]
    versions[currentversion] = []
  else
    versions[currentversion] << line
  end
end
versions.delete(nil)

def prompt(*args)
  print(*args)
  gets.chomp
end

newest = versions.first[0]
version = prompt "Version [#{newest}]: "
version = newest if version.empty?

unless versions[version]
  $stderr.puts "Version #{version} is invalid. Valid versions are: #{versions.keys.join(', ')}"
  exit 4
end

tagname = "v#{version}"



result = Open3.capture3("git rev-parse #{tagname}")
if result[2].exitstatus == 0
  $stderr.puts "Tag #{tagname} already exists."
  exit 5
end

commit = prompt "Commit: "

result = Open3.capture3("git --no-pager log -1 #{commit} --format='%ci'")
unless result[2].exitstatus == 0
  $stderr.puts "Commit '#{commit}' is not valid."
  exit result[2].exitstatus
end
commitdate = result[0].lines.first.chomp

def word_wrap(line, width)
  first_prefix = line.match(/([ -]*)/)[1]
  prefix = ' ' * first_prefix.size
  real_width = width - (prefix.size * 2)
  line[prefix.size..-1].gsub(/(^)?(.{1,#{real_width}})(?: +|$)/) { |s| $1 ? "#{first_prefix}#{s}\n" : "#{prefix}#{s}\n" }
end

require 'tempfile'
begin
  tf = Tempfile.new('tag-message')
  tf.puts "Version #{version} release"
  tf.puts ""
  tf.puts "Changes:"
  versions[version].each do |line|
    tf.puts word_wrap(line, 80)
  end
  tf.flush

  result = Open3.capture3({'GIT_COMMITTER_DATE' => commitdate}, "git tag -a #{tagname} #{commit} -F #{tf.path}")
  $stderr.puts result[1]
  if result[2].exitstatus == 0
    system "git --no-pager show #{tagname} --no-patch"
    puts ""
    puts "Tag created. Please push to GitHub with `git push origin #{tagname}`."
  end
  exit result[2].exitstatus
ensure
  tf.close!
end
