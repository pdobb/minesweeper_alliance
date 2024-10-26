# frozen_string_literal: true

# AbstractBaseClassBehaviors is a mix-in for making the including class into an
# "Abstract Base Class". i.e. to make it so that it can't be instantiated.
#
# @example
#   class MyBaseClass
#     include AbstractBaseClassBehaviors
#
#     as_abstract_class
#   end
module AbstractBaseClassBehaviors
  extend ActiveSupport::Concern

  class_methods do
    def as_abstract_class
      @abstract_class = self

      define_singleton_method(:new) do |*args, &block|
        if as_abstract_class?
          raise(
            NotImplementedError,
            "#{self} is an abstract class and cannot be instantiated.")
        end

        super(*args, &block)
      end
    end

    def as_abstract_class?
      !!(@abstract_class == self)
    end
  end
end
