require_relative 'db_connection'
require_relative 'relation'

module Searchable
  def find_by(params)
    search_datum = DBConnection.get_first_row(<<-SQL, params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line(params)}
    SQL

    self.new(search_datum)
  end

  def where(params)
    query_hdoc = <<-SQL
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line(params)}
    SQL

    Relation.new(query_hdoc, params.values, self)
  end

  private
  def where_line(params)
    params.keys.map { |param| "#{param} = ?"}.join(' AND ')
  end
end
