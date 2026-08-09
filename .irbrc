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

# OBJECT INSPECTOR GEM

ObjectInspector.configure do |config|
  config.enabled = true
end

def toggle_object_inspector = ObjectInspector.configuration.toggle
alias oit toggle_object_inspector

def get_object_inspector_current_scope # rubocop:disable Naming/AccessorMethodName
  ObjectInspector.configuration.default_scope
end
alias oi get_object_inspector_current_scope

# :self is the default inspection scope.
def set_object_inspector_scope_self = set_object_inspector_scope(:self)
alias ois set_object_inspector_scope_self

def set_object_inspector_scope_complex = set_object_inspector_scope(:complex)
alias oic set_object_inspector_scope_complex

def set_object_inspector_scope_verbose = set_object_inspector_scope(:verbose)
alias oiv set_object_inspector_scope_verbose

# Set :all (wild-card) inspection scope.
def set_object_inspector_scope_all = set_object_inspector_scope(:all)
alias oia set_object_inspector_scope_all

# Set a custom scope or set of scopes.
#
# @example
#   set_object_inspector_scope(:my_custom_scope)
#   set_object_inspector_scope(:complex, :verbose)
#   set_object_inspector_scope(%i[complex verbose my_custom_scope])
def set_object_inspector_scope(*names)
  ObjectInspector.configuration.default_scope = *names
  get_object_inspector_current_scope
end
alias oiset set_object_inspector_scope
