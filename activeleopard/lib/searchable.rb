require_relative 'db_connection'
require_relative 'relation'
require_relative 'errors'

module Searchable
  def find_by(params)
    where_clause = WhereClause.new([params])

    search_datum = DBConnection.get_first_row(<<-SQL, where_clause.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_clause.as_sql}
    SQL

    search_datum.nil? ? nil : self.new(search_datum)
  end

  def where(*params)
    Relation.new(
      {where: WhereClause.new(params)},
      self
    )
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

  def joins(association, _ = nil)
    options = self.assoc_options[association]

    Relation.new(
      {join: JoinOptions.new(options, self.table_name)},
      self
    )
  end

  def select(*params)
    Relation.new(
      {select: SelectClause.new(params)},
      self
    )
  end

  def group(group_attr)
    Relation.new(
      {group: GroupClause.new(group_attr)},
      self
    )
  end

  def order(ordering_attr)
    Relation.new(
      {order: OrderClause.new(ordering_attr)},
      self
    )
  end
end
