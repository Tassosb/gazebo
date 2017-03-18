class SelectClause
  attr_accessor :distinct, :params

  def initialize(params = [])
    @distinct = false
    @params = params
  end

  def as_sql
    "SELECT " +
    "#{distinct ? 'DISTINCT ' : ''}" +
    "#{params_as_sql}"
  end

  def params_as_sql
    params.map(&:to_s).join(', ')
  end
end
