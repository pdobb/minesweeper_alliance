# frozen_string_literal: true

desc "Validate that the app loads in a production-like environment"
task :validate_env do # rubocop:disable Rails/RakeEnvironment
  command = "bin/validate_env"
  success = system(command)

  unless success
    puts("\e[31mvalidation failed\e[0m")
    abort
  end
end
