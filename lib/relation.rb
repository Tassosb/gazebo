require_relative 'db_connection'
require_relative 'search_params'

class Relation
  include Enumerable

  attr_reader :query, :cache, :source_class, :data

  def defaults
    {
      select: SelectClause.new(["#{source_class.table_name}.*"]),
      from: FromClause.new(source_class.table_name),
      join: JoinOptions.new,
      where: WhereClause.new,
      limit: LimitClause.new,
      group: GroupClause.new
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

  def select(*params)
    query[:select].params = params
    self
  end

  def distinct
    query[:select].distinct = true
    self
  end

  def group(grouping_attr)
    query[:group].grouping_attr = grouping_attr
    self
  end

  def as_sql
    [:select, :from, :join, :where, :group, :limit].map do |clause|
      query[clause].as_sql
    end.join(" \n ")
  end

  def as_json
    execute! if cache.nil?
    cache
  end

  def each(&prc)
    to_a.each { |el| prc.call(el) }
  end

  def bind_params
    query[:where].values
  end

  def to_a
    execute! if cache.nil?
    cache.map { |datum| source_class.new(datum) }
  end

  def execute!
    @cache = DBConnection.execute(as_sql, bind_params)
  end

  def inspect
    p to_a
  end

  def empty_cache!
    @cache = nil
  end
end
