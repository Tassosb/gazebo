require_relative 'errors'

class SearchParams
  def initialize(params)
    @params = params
  end

  def values
    if first.is_a?(String)
      return [] if last == first
      last.is_a?(Array) ? last : [last]
    elsif first.is_a?(Hash)
      first.values
    end
  end

  def where_line
    if first.is_a?(String)
      string_where_line
    elsif first.is_a?(Hash)
      first.keys.map { |param| "#{param} = ?"}.join(' AND ')
    else
      raise InvalidInput, "Argument must be a string or hash"
    end
  end

  private
  attr_reader :params

  def last
    params.last
  end

  def first
    params.first
  end

  def string_where_line
    first.gsub('(?)') do
      "(#{(['?'] * values.count).join(', ')})"
    end
  end
end
