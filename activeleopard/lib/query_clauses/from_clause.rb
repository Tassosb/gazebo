class FromClause
  attr_reader :table_name

  def initialize(table_name)
    @table_name = table_name
  end

  def as_sql
    "FROM #{table_name}"
  end
end
