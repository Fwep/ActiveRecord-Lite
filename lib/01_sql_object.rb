require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    return @columns if @columns
    query = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @columns = query[0].map(&:to_sym)
  end

  def self.finalize!
    columns.each do |attr|
      define_method(attr) do
        self.attributes[attr] ||= nil
      end

      define_method("#{attr}=") do |val|
        self.attributes[attr] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= name.tableize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end

end
