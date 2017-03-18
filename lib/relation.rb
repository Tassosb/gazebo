require_relative 'db_connection'
require_relative 'search_params'

class Relation
  include Enumerable

  attr_reader :query, :cache, :source_class

  def defaults
    {
      select: "#{source_class.table_name}.*",
      where: WhereClause.new,
      join: JoinOptions.new,
      limit: LimitClause.new
    }
  end

  def initialize(query, source_class)
    @source_class = source_class
    @query = defaults.merge(query)
    @cache = nil
  end

  def where(*where_params)
    query[:where] << where_params
    empty_cache!
    self
  end

  def joins(association, join_class = source_class)
    options = join_class.assoc_options[association]
    query[:join].append(options, join_class.table_name)
    empty_cache!
    self
  end

  def limit(n)
    query[:limit].set(n)
    self
  end

  def as_sql
    sql = <<-SQL
      SELECT #{query[:select]}
      FROM #{source_class.table_name}
    SQL

    [:join, :where, :limit].each do |clause|
      sql << query[clause].as_sql
    end

    sql
  end

  def each(&prc)
    to_a.each { |el| prc.call(el) }
  end

  def bind_params
    query[:where].values
  end

  def to_a
    return cache if cache
    data = DBConnection.execute(as_sql, bind_params)
    @cache = data.map { |datum| source_class.new(datum) }
  end

  def inspect
    p to_a
  end

  def empty_cache!
    @cache = nil
  end
end
