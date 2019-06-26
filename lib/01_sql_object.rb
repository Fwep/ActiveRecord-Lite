require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    return @columns if @columns
    # #execute2 just makes it more convenient to grab the columns
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
   results = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |res|
      parse(res)
    end
  end

  def self.parse(res)
    self.new(res)
  end

  def self.find(id)
    res = DBConnection.instance.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL
    return nil if res[0].nil?
    parse(res[0])
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map {|attr| self.send(attr)}
  end

  def insert
    col_names = self.class.columns[1..-1].join(', ')
    question_marks = (["?"] * self.class.columns[1..-1].length).join(', ')
    attribute_values = self.attribute_values[1..-1]

    DBConnection.instance.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
       (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
  end

  def save
    # ...
  end

end
