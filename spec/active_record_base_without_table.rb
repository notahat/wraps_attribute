require 'active_record'

# This is based on Jonathan Viney's active_record_base_without_table plugin:
#
#   http://svn.viney.net.nz/things/rails/plugins/active_record_base_without_table/ 
module ActiveRecord
  class BaseWithoutTable < Base
    self.abstract_class = true
    
    def save
      valid?
    end
    
    class << self
      def columns()
        @columns ||= []
      end
      
      def column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        reset_column_information
      end
      
      # Do not reset @columns
      def reset_column_information
        generated_methods.each { |name| undef_method(name) }
        @column_names = @columns_hash = @content_columns = @dynamic_methods_hash = @read_methods = nil
      end
    end
  end
end