# frozen_string_literal: true

desc "Validate that the app loads in a production-like environment"
task :validate do # rubocop:disable Rails/RakeEnvironment
  success = system("bin/validate")

  unless success
    puts("\e[31mValidation failed\e[0m")
    abort
  end
end
