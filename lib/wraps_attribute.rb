module ActiveRecord
  module WrapsAttribute
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    module ClassMethods
      def wraps_attribute(attribute, wrapper_class, options = {})
        options = { :validate => :valid?, :message => "must be valid" }.merge(options)
        
        before_validation {|object| object.send(:write_attribute, attribute, object.send(attribute).normalize) }

        if options[:validate]
          validate do |object|
            unless (options[:allow_blank] && object.send(attribute).blank?) || object.send(attribute).send(options[:validate])
              object.errors.add(attribute, options[:message])
            end
          end
        end
        
        define_method(attribute) do
          unless read_attribute(attribute).is_a?(wrapper_class)
            write_attribute(attribute, wrapper_class.new(read_attribute(attribute)))
          end
          read_attribute(attribute)
        end        
      end
    end
  end
  
  class Base
    include WrapsAttribute
  end
end
