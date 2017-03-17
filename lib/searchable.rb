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

  def parse_all(all_options)
    all_options.map { |options| self.new(options) }
  end

  def find(id)
    found_data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
    SQL

    parse_all(found_data).first
  end
end
