require_relative 'db_connection'

class Relation
  include Enumerable

  attr_reader :query, :params, :source_class

  def initialize(query, params, source_class)
    @query = query.scan(/\S+/).join(' ')
    @params, @source_class = params, source_class
  end

  def update(add_query, add_params)
    @query += add_query
    params.concat(add_params)
  end

  def where(params)
    add_to_hdoc = " AND #{where_line(params)}"

    update(add_to_hdoc, params.values)
    self
  end

  def where_line(params)
    params.keys.map { |param| "#{param} = ?"}.join(' AND ')
  end

  def each(&prc)
    to_a.each { |el| prc.call(el) }
  end

  def to_a
    puts "#{query}, #{params}"
    data = DBConnection.execute(query, params)
    data.map { |datum| source_class.new(datum) }
  end
end
