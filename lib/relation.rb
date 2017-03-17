require_relative 'db_connection'
require_relative 'search_params'

class Relation
  include Enumerable

  attr_reader :query, :params, :source_class


  def defaults
    {
      select: "#{source_class.table_name}.*",
      where: [],
      join: []
    }
  end

  def initialize(query, params, source_class)
    @source_class = source_class
    @query = defaults.merge(query)
    @params = params
  end

  def where(*where_params)
    search_params = SearchParams.new(where_params)
    query[:where] << search_params.where_line
    params.concat(search_params.values)
    self
  end

  def build_query
    sql = <<-SQL
      SELECT #{query[:select]}
      FROM #{source_class.table_name}
    SQL
    
    sql << query[:join].map { |clause| " JOIN #{clause} \n" }.join
    sql << "WHERE " + query[:where].join(" AND ") unless query[:where].empty?
    sql
  end

  def join_clauses
    query[:join].map { |clause| "\n JOIN #{clause}" }.join
  end

  def each(&prc)
    to_a.each { |el| prc.call(el) }
  end

  def to_a
    data = DBConnection.execute(build_query, params)
    data.map { |datum| source_class.new(datum) }
  end

  def inspect
    p to_a
  end
end
