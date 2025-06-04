# Cucumber does not have built-in support for waiting on stderr; the following
# is a copy of the corresponding "wait for stdout", with stderr substituted for
# stdout.
# https://github.com/cucumber/aruba/blob/0cbd0e826994a67259b242c7befdb956552246e8/lib/aruba/cucumber/command.rb#L116-L129
When('I wait for stderr to contain {string}') do |expected|
  Timeout.timeout(aruba.config.exit_timeout) do
    loop do
      output = last_command_started.stderr wait_for_io: 0

      output   = sanitize_text(output)
      expected = sanitize_text(expected)

      break if output.include? expected

      sleep 0.1
    end
  end
end

# Cucumber does not have built-in support for regex match against stdin or
# stdout (only "output", which inclues both at once).
Then(%r{^the (stdout|stderr) should( not)? match /([^/]*)/$}) do |channel, negated, expected|
  matcher = case channel
            when 'stderr'; then :have_output_on_stderr
            when 'stdout'; then :have_output_on_stdout
            end
  if negated
    expect(all_commands)
      .not_to include send(matcher, an_output_string_matching(expected))
  else
    expect(all_commands)
      .to include send(matcher, an_output_string_matching(expected))
  end
end
