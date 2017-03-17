require_relative 'db_connection'
require_relative 'relation'
require_relative 'search_params'
require_relative 'errors'

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

    # query_hdoc = <<-SQL
    #   SELECT
    #     *
    #   FROM
    #     #{self.table_name}
    #   WHERE
    #     #{search_params.where_line}
    # SQL

    query = {
      where: [search_params.where_line]
    }

    Relation.new(query, search_params.values, self)
  end

  def find(id)
    search_datum = DBConnection.get_first_row(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
    SQL

    search_datum.nil? ? nil : self.new(search_datum)
  end

  def join_on(assoc_options)
    if assoc_options.is_a?(BelongsToOptions)
      own_column = assoc_options.foreign_key
      other_column = assoc_options.primary_key
    elsif assoc_options.is_a?(HasManyOptions)
      own_column = assoc_options.primary_key
      other_column = assoc_options.foreign_key
    end

    "#{self.table_name}.#{own_column}" +
    " = " + "#{assoc_options.table_name}.#{other_column}"
  end

  def joins(association)
    options = self.assoc_options[association]

    unless options
      raise InvalidInput, "Argument must be an association(type: symbol)"
    end

    # query_hdoc = <<-SQL
    #   SELECT
    #     #{self.table_name}.*
    #   FROM
    #     #{self.table_name}
    #   INNER JOIN
    #     #{options.table_name} ON #{join_on(options)}
    # SQL

    query = {
      join: ["#{options.table_name} ON #{join_on(options)}"]
    }

    Relation.new(query, [], self)
  end
end
