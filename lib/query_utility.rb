require_relative 'errors'

module QueryUtility
  def where_line(params)
    if params.is_a?(String)
      params
    elsif params.is_a?(Hash)
      params.keys.map { |param| "#{param} = ?"}.join(' AND ')
    else
      raise InvalidInput, "Argument must be a string or hash"
    end
  end
end
