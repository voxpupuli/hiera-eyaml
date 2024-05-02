begin
  require 'simplecov'
  require 'simplecov-console'
  require 'codecov'
rescue LoadError
else
  SimpleCov.start do
    track_files 'lib/**/*.rb'

    add_filter '/spec'

    enable_coverage :branch

    # do not track vendored files
    add_filter '/vendor'
    add_filter '/.vendor'
  end

  SimpleCov.formatters = [
    SimpleCov::Formatter::Console,
    SimpleCov::Formatter::Codecov,
  ]
end

# https://cucumber.io/docs/tools/ruby/
# https://stackoverflow.com/questions/6473419/using-simplecov-to-display-cucumber-code-coverage
require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = %w[--format progress] # Any valid command line option can go here.
end

begin
  require 'github_changelog_generator/task'
rescue LoadError
  # Do nothing if no required gem installed
else
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    version = Hiera::Backend::Eyaml::VERSION
    config.future_release = "v#{version}" if /^\d+\.\d+.\d+$/.match?(version)
    config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file."
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog]
    config.user = 'voxpupuli'
    config.project = 'hiera-eyaml'
  end
end

begin
  require 'voxpupuli/rubocop/rake'
rescue LoadError
  # the voxpupuli-rubocop gem is optional
end
