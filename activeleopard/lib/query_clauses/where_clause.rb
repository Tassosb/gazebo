require_relative '../errors'

class WhereClause
  def initialize(options = [])
    unless options.is_a?(Array) && options.length <= 2
      raise InvalidInput, "Where takes 1 or 2 arguments"
    end

    @conditions = parse_conditions(options)
  end

  def values
    conditions.values.flatten
  end

  def as_sql
    return "" if conditions.empty?
    " WHERE " + conditions_as_sql
  end

  def append(options)
    conditions.merge!(parse_conditions(options))
  end

  alias_method :<<, :append

  private
  attr_reader :bind_params, :conditions

  def conditions_as_sql
    conditions.map do |condition, values|
      if condition.is_a?(String)
        format_condition(condition, values)
      elsif condition.is_a?(Symbol)
        "#{condition} = ?"
      end
    end.flatten.join(' AND ')
  end

  def parse_params(params_input)
    return [] if params_input.nil?
    params_input.is_a?(Array) ? params_input : [params_input]
  end

  def parse_conditions(input)
    if input.first.is_a?(String)
      { input.first => parse_params(input[1]) }
    elsif input.first.is_a?(Hash)
      input.first
    else
      {}
    end
  end

  def format_condition(condition, values)
    condition.gsub('(?)') do
      "(#{(['?'] * values.count).join(', ')})"
    end
  end
end
