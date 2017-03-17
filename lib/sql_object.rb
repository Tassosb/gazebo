require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

class SQLObject
  extend Associatable
  extend Searchable

  def self.columns
    return @columns if @columns

    cols = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      from
        #{self.table_name}
    SQL

    @columns = cols.map(&:to_sym)
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

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize.gsub('humen') { 'humans' }
  end

  def self.all
    all_hashes = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    parse_all(all_hashes)
  end

  def self.parse_all(all_options)
    all_options.map { |options| self.new(options) }
  end

  def self.find(id)
    found_data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
    SQL

    parse_all(found_data).first
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

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_name = attr_name.to_sym

      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end

      send("#{attr_name}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def col_names
    self.class.columns
      .map(&:to_s)
      .drop(1).join(', ')
  end

  def attr_count
    @attributes.count
  end

  def attr_values_to_update
    attributes.reject { |attr_name, _| attr_name == :id }.values
  end

  def question_marks
    (["?"] * attributes.count).join(', ')
  end

  def update_set_line
    col_names.split(', ').map { |c| "#{c} = ?" }.join(', ')
  end

  def update
    DBConnection.execute(<<-SQL, (attr_values_to_update << id))
      UPDATE
        #{self.class.table_name}
      SET
        #{update_set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    id ? update : insert
  end
end
