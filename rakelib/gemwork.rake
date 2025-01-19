# frozen_string_literal: true

return unless Rails.env.development?

spec = Gem::Specification.find_by_name("gemwork")

# Load additional tasks defined by Gemwork.
Dir.glob(
  Pathname.new(spec.gem_dir).
    join("lib", "tasks", "{util,rubocop,reek,eslint,prettier}.rake")) do |task|
  load(task)
end

# Redefine the default `rake` task.
Rake::Task["default"].clear
task :default do
  run_tasks(%i[
    test
    rubocop
    reek
    eslint
    prettier
    validate_env
  ])
end
