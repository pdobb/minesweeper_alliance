# frozen_string_literal: true

# Remove "Inter" font loading in from the tailwindcss-rail gem.
# See: See: https://github.com/rails/tailwindcss-rails/discussions/353

if Gem::Version.new(Tailwindcss::VERSION) >= "3"
  raise("Reassess the need for this hack w/ Tailwindcss v3+.")
end

Rails.application.config.to_prepare do
  Rails.application.config.assets.precompile -= ["inter-font.css"]
  Rails.application.config.assets.paths.reject! { |path|
    path.is_a?(String) && path.include?("gems/tailwindcss-rails")
  }
end
