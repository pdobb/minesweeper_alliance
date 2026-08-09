# frozen_string_literal: true

require "puma/plugin"

PUMA_DEV_URLS = [
  "https://minesweeperalliance.test",
].freeze

LOCAL_ENVS = %w[
  development
].freeze

# Puma plugin that displays the Puma-dev URL for this app in the server startup
# output--after Puma's "Listening on" lines and before the "Use Ctrl-C to stop"
# line.
#
# @example
#   $ bin/rails s
#   => Booting Puma
#   => Rails 8.1.3.1 application starting in development
#   => Run `bin/rails server --help` for more startup options
#   Puma starting in single mode...
#   * Puma version: 8.0.2 ("Into the Arena")
#   * Ruby version: ruby 4.0.6 (2026-07-14 revision 03b6d3f889) +PRISM [arm64-darwin27]
#   *  Min threads: 3
#   *  Max threads: 3
#   *  Environment: development
#   *          PID: 60553
#   * Listening on http://127.0.0.1:3000
#   * Listening on http://[::1]:3000
#   * Puma-dev URL: https://minesweeperalliance.test
#   Use Ctrl-C to stop
#
# Notes:
#
# - It would be cleaner to use Puma's `on_booted` hook, but that fires after the
#   "Use Ctrl-C to stop" output, which is less clean looking.
#   - See https://github.com/puma/puma/blob/v5.3.2/lib/puma/single.rb#L58
#
#   So we monkey-patch Runner#load_and_bind instead:
#   - See: https://github.com/puma/puma/blob/v5.3.2/lib/puma/runner.rb#L136
Puma::Plugin.create do
  # :reek:TooManyStatements
  def start(_launcher)
    return if Puma::Runner.method_defined?(:load_and_bind_without_puma_dev_urls)

    Puma::Runner.class_eval do
      alias_method(:load_and_bind_without_puma_dev_urls, :load_and_bind)

      define_method(:load_and_bind) do
        load_and_bind_without_puma_dev_urls
        return if LOCAL_ENVS.exclude?(@options[:environment])

        log("* Puma-dev URL: #{PUMA_DEV_URLS.join(", ")}")
      end
    end
  end
end
