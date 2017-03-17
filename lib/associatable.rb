require 'active_support/inflector'
require 'byebug'
require_relative 'searchable'
require_relative 'assoc_options'

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      foreign_key_val = self.send(options.foreign_key)
      return nil if foreign_key_val.nil?

      options
        .model_class
        .where(options.primary_key => foreign_key_val)
        .first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    assoc_options[name] = options

    define_method(name) do
      primary_key_val = self.send(options.primary_key)

      options.model_class
        .where(options.foreign_key => primary_key_val)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.model_class.table_name
      source_table = source_options.model_class.table_name

      datum = DBConnection.execute(<<-SQL).first
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_options.foreign_key} =
              #{source_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key} =
                  #{self.send(through_options.foreign_key)}
      SQL

      source_options.model_class.new(datum)
    end
  end

  def has_many_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]
      through_table = through_options.model_class.table_name
      source_table = source_options.model_class.table_name

      data = DBConnection.execute(<<-SQL)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
          ON #{through_table}.#{source_options.primary_key} =
              #{source_table}.#{source_options.foreign_key}
        WHERE
          #{through_table}.#{through_options.foreign_key} =
                #{self.id}
      SQL

      data.map { |datum| source_options.model_class.new(datum) }
    end
  end
end
