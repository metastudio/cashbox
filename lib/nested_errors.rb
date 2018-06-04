# frozen_string_literal: true

module NestedErrors
  def self.unflatten(object, relationships)
    errors = object.errors.messages.to_hash
    return errors if relationships.blank?

    relationships.each do |relationship|
      errors[relationship] = {}
      association = object.__send__(relationship)
      if association.respond_to?(:each_with_index)
        association.each_with_index do |child, index|
          next if child.errors.messages.blank?
          errors[relationship][index] = {}
          child.errors.messages.map do |field, e|
            errors[relationship][index][field] = e if e.present?
          end
        end
      else
        association.errors.messages.map do |field, e|
          errors[relationship][field] = e if e.present?
        end
      end
    end
    errors
  end
end
