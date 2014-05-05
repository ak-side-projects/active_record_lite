require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    column_set = params.keys.map { |col| "#{col} = ?"}
    column_set = column_set.join(" AND ")
    new_str = ""
    values = params.values
    values = values[0] if values.count == 1
    results = DBConnection.execute(<<-SQL, values)
      SELECT *
      FROM #{self.table_name}
      WHERE #{column_set}
    SQL

    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
