# frozen_string_literal: true

# AbstractBaseClassBehaviors is a mix-in for making the including class into an
# "Abstract Base Class". i.e. to make it so that it can't be instantiated.
#
# @example
#   class MyBaseClass
#     include AbstractBaseClassBehaviors
#
#     abstract_base_class
#   end
module AbstractBaseClassBehaviors
  extend ActiveSupport::Concern

  class_methods do
    def abstract_base_class
      @abstract_class = self

      # def self.new(*args, **kwargs, &block)
      #   ...
      #   super(*args, **kwargs, &block)
      # end
      define_singleton_method(:new) do |*args, **kwargs, &block|
        if abstract_base_class?
          raise(
            NotImplementedError,
            "#{self} is an abstract base class and cannot be instantiated.")
        end

        super(*args, **kwargs, &block)
      end
    end

    def abstract_base_class?
      @abstract_class == self
    end
  end
end
