class LimitClause
  attr_reader :num

  def initialize(num = nil)
    @num = num
  end

  def as_sql
    num.nil? ? "" : "LIMIT #{num} "
  end

  def set(n)
    @num = n
  end
end
