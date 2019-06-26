require_relative '03_associatable'

module Associatable
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      table = through_options.table_name
      model_table = source_options.table_name

     res =  DBConnection.instance.execute(<<-SQL, self.send(through_options.foreign_key))
        SELECT
         #{model_table}.*
        FROM
          #{table}
        JOIN
          #{model_table} ON #{table}.#{source_options.foreign_key.to_s} = #{model_table}.#{source_options.primary_key.to_s}
        WHERE
          #{table}.id = ?
      SQL
      source_options.model_class.parse(res[0])
    end
  end
end
