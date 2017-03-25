class SQLObject
  def self.after_initialize(method_name)
    callbacks[:after_initialize] = method_name
  end

  def self.all
    Relation.new({}, self)
  end

  def self.callbacks
    @callbacks ||= {}
  end

  def self.columns
    return @columns if @columns

    cols = DBConnection.execute(<<-SQL, [self.table_name])
      SELECT
        column_name
      FROM
        information_schema.columns
      WHERE
        table_name = $1
    SQL

    @columns = cols.map { |c| c['column_name'].to_sym }
  end

  def self.destroy_all
    DBConnection.execute(<<-SQL)
      DELETE FROM #{self.table_name}
    SQL
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do #setter method
        attributes[col]
      end

      define_method("#{col}=") do |val| #getter method
        attributes[col] = val
      end
    end
  end

  def self.first
    first_data = DBConnection.get_first_row(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    ORDER BY
      id
    LIMIT
      1
    SQL

    self.new(first_data)
  end

  def self.last
    last_data = DBConnection.get_first_row(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    ORDER BY
      id DESC
    LIMIT
      1
    SQL

    self.new(last_data)
  end

  def self.parse_all(all_options)
    all_options.map { |options| self.new(options) }
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize.gsub('humen') { 'humans' }
  end

  def self.validations
    @validations ||= []
  end

  def attributes
    @attributes ||= {}
  end

  def attr_count
    @attributes.count
  end

  def attribute_values
    attributes.values
  end

  def attr_values_to_update
    attributes.reject { |attr_name, _| attr_name == :id }.values
  end

  def col_names
    self.class.columns
    .map(&:to_s)
    .drop(1).join(', ')
  end

  def destroy
    DBConnection.execute(<<-SQL, [self.id])
      DELETE FROM #{self.class.table_name}
      WHERE id = $1
    SQL
  end

  def errors
    @errors ||= Hash.new { |h, k| h[k] = [] }
  end

  def initialize(params = {})
    self.class.columns.each do |attr_name|
      params_val = params[attr_name] || params[attr_name.to_s]
      params_val.strip! if params_val
      send("#{attr_name}=", params_val)
    end

    params.each do |attr_name, val|
      next if self.class.columns.include?(attr_name.to_sym)
      val.strip! if val
      send("#{attr_name}=", val)
    end

    if self.class.callbacks[:after_initialize]
      send(self.class.callbacks[:after_initialize])
    end
  end

  def insert
    result = DBConnection.execute(<<-SQL, attr_values_to_update)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
    RETURNING
      id
    SQL

    self.id = result.getvalue(0,0)
  end

  def question_marks
    (1...attributes.count).map { |n| "$#{n}"}.join(', ')
  end

  def save
    validate!
    if valid?
      id ? update : insert
      true
    else
      show_errors
      false
    end
  end

  def show_errors
    errors.each do |key, messages|
      messages.each { |m| puts "#{key} #{m}" }
    end
  end

  def to_s
    "#{self.class}:#{self.object_id}"
  end

  def update_set_line
    col_names.split(', ').map.with_index { |c, i| "#{c} = $#{i + 1}" }.join(', ')
  end

  def update
    vals = attr_values_to_update << id
    DBConnection.execute(<<-SQL, vals)
      UPDATE
        #{self.class.table_name}
      SET
        #{update_set_line}
      WHERE
        id = $#{vals.length}
    SQL
  end

  def validate!
    @errors = Hash.new { |h, k| h[k] = [] }

    self.class.validations.each do |validation|
      self.send(validation)
    end
  end

  def valid?
    validate!
    errors.all? { |_, v| v.empty? }
  end
end
