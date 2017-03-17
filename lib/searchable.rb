require_relative 'db_connection'
require_relative 'relation'
require_relative 'search_params'

module Searchable
  def find_by(params)
    search_params = SearchParams.new([params])

    search_datum = DBConnection.get_first_row(<<-SQL, search_params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{search_params.where_line}
    SQL

    search_datum.nil? ? nil : self.new(search_datum)
  end

  def where(*params)
    search_params = SearchParams.new(params)

    query_hdoc = <<-SQL
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{search_params.where_line}
    SQL

    Relation.new(query_hdoc, search_params.values, self)
  end
end
