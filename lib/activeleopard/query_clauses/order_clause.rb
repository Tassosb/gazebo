class OrderClause
  attr_accessor :ordering_attr

  def initialize(ordering_attr = nil)
    @ordering_attr = ordering_attr
  end

  def as_sql
    return "" if ordering_attr.nil?
    "ORDER BY #{ordering_attr.to_s}"
  end
end
