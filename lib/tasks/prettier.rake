# frozen_string_literal: true

desc "Run prettier on **/*.{js,yml,md}"
task :prettier do # rubocop:disable Rails/RakeEnvironment
  sh("npx prettier . --check")
end
