require_relative '../assoc_options'

class JoinClause
  def initialize(assoc_options, source_table)
    unless assoc_options
      raise InvalidInput, "Argument must be an association(type: symbol)"
    end

    @assoc_options = assoc_options
    @source_table = source_table
  end

  def other_table
    assoc_options.table_name
  end

  def on_clause
    # if assoc_options.is_a?(BelongsToOptions)
    #   own_column = assoc_options.foreign_key
    #   other_column = assoc_options.primary_key
    # elsif assoc_options.is_a?(HasManyOptions)
    #   own_column = assoc_options.primary_key
    #   other_column = assoc_options.foreign_key
    # end

    "#{source_table}.#{assoc_options.own_join_column}" +
    " = " + "#{other_table}.#{assoc_options.other_join_column}"
  end

  def as_sql
    "JOIN #{other_table} ON #{on_clause} "
  end

  attr_reader :assoc_options, :source_table
end

class JoinOptions
  attr_reader :clauses

  def initialize(assoc_options = nil, source_table = nil)
    @clauses = []
    if assoc_options && source_table
      @clauses << JoinClause.new(assoc_options, source_table)
    end
  end

  def as_sql
    clauses.map(&:as_sql).join(" \n ")
  end

  def append(assoc_options, source_table)
    clauses << JoinClause.new(assoc_options, source_table)
  end
end
