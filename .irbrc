# frozen_string_literal: true

# Store the last `n` evaluations (returned values).
# See: https://ruby.github.io/irb/#label-Evaluation+History
IRB.conf[:EVAL_HISTORY] = 10

# Add commonly used aliases from Pry.
# See: https://ruby.github.io/irb/#label-Command+Aliases
IRB.conf[:COMMAND_ALIASES].update(
  "?": :show_doc,
  "!!!": :exit!,
)

def eager_load! = Rails.application.eager_load!

# Toggle display of SQL query logging. Query logging defaults to 'on' in
# development, but can sometimes be too much (even slowing things down in
# extreme cases).
def toggle_query_logging # rubocop:disable Metrics/MethodLength
  @old_logger ||= ActiveRecord::Base.logger

  new_logger =
    if ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil
      "nil"
    else # Toggle on
      ActiveRecord::Base.logger = @old_logger
      @old_logger.class.name
    end
  Say.("ActiveRecord::Base.logger = #{new_logger}")
  nil
end

# Toggle display of originating Ruby source file:<line> to logged SQL queries.
# Defaults to 'off' in the Rails console regardless of whatever
# `Rails.application.config.active_record.verbose_query_logs` might be set to.
# See: https://github.com/rails/rails/commit/1044e8b355930e8cb14d1f182d33a561fdaca65b
def toggle_verbose_query_logs
  ActiveRecord::Base.verbose_query_logs = !ActiveRecord::Base.verbose_query_logs
  state = ActiveRecord::Base.verbose_query_logs
  Say.("ActiveRecord::Base.verbose_query_logs = #{state}")
  nil
end
