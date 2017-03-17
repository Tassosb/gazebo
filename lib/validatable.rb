module Validatable
  def validates(attribute, options)
    method_name = "validate_#{attribute}"

    define_method(method_name) do
      attr_val = self.send(attribute)
      
      if options[:presence]
        if attr_val.nil?
          errors[attribute] = "can't be blank"
        end
      end

      if options[:uniqueness]
        matching_obj = self.class.find_by(attribute => attr_val)

        unless matching_obj.nil? || matching_obj.id == self.id
          errors[attribute] = "must be unique"
        end
      end
    end

    self.validations << method_name
  end
end
