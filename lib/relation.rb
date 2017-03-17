require_relative 'db_connection'
require_relative 'search_params'

class Relation
  include Enumerable

  attr_reader :query, :params, :source_class

  def initialize(query, params, source_class)
    @query = query.scan(/\S+/).join(' ')
    @params = params
    @source_class = source_class
  end

  def update(add_query, add_params)
    @query += add_query
    params.concat(add_params)
  end

  def where(*params)
    search_params = SearchParams.new(params)
    add_to_query = " AND #{search_params.where_line}"
    update(add_to_query, search_params.values)
    self
  end

  def each(&prc)
    to_a.each { |el| prc.call(el) }
  end

  def to_a
    data = DBConnection.execute(query, params)
    data.map { |datum| source_class.new(datum) }
  end

  def inspect
    p to_a
  end
end
