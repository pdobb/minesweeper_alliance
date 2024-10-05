# frozen_string_literal: true

require "active_record/connection_adapters/postgresql_adapter"

# https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/PostgreSQLAdapter.html#method-c-datetime_type
# https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_timestamp_.28without_time_zone.29
# https://dev.to/jonathanfrias/handling-timezones-in-rails-2ibn
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type = :timestamptz
