class GroupClause
  attr_accessor :grouping_attr

  def initialize(grouping_attr = nil)
    @grouping_attr = grouping_attr
  end

  def as_sql
    return "" if grouping_attr.nil?
    "GROUP BY #{grouping_attr.to_s}"
  end
end
