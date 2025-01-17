# frozen_string_literal: true

# Augment Say gem to include a silent version of `Say.call`.

def Say.silent(...)
  old_logger = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = nil

  call(...)
ensure
  ActiveRecord::Base.logger = old_logger
end
