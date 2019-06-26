require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map {|param| "#{param.to_s} = ?"}.join(' AND ')
    res = DBConnection.instance.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    res.map {|row| self.new(row)}
  end
end

class SQLObject
  # Mixin Searchable here...
  self.extend(Searchable)
end
