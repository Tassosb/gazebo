class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    name = name.to_s.singularize

    defaults = {
      foreign_key: ("#{name.underscore}_id").to_sym,
      class_name: name.camelcase,
      primary_key: :id
    }

    defaults.merge(options).each do |option, opt_name|
      send("#{option}=", opt_name)
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    name = name.to_s.singularize
    self_class_name = self_class_name.to_s.singularize

    defaults = {
      foreign_key: ("#{self_class_name.underscore}_id").to_sym,
      class_name: name.camelcase,
      primary_key: :id
    }

    defaults.merge(options).each do |option, opt_name|
      send("#{option}=", opt_name)
    end
  end
end
