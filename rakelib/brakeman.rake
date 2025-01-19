# frozen_string_literal: true

# rubocop:disable Rails/RakeEnvironment
desc "Run Brakeman"
task(:brakeman, :output_files) do |_task, args|
  require "brakeman"

  files = args[:output_files].split if args[:output_files]
  Brakeman.run(
    app_path: ".",
    quiet: true,
    output_files: files,
    print_report: true,
    summary_only: true,
    pager: false)
end
# rubocop:enable Rails/RakeEnvironment
