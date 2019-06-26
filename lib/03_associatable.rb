require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      primary_key: :id,
      foreign_key: "#{name.to_s.singularize}_id".to_sym,
      class_name: "#{name.to_s.singularize.camelcase}"
    }

    defaults.keys.each {|key| self.send("#{key}=", options[key] ? options[key] : defaults[key])}
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})

    defaults = {
      primary_key: :id,
      foreign_key: "#{self_class_name.underscore}_id".to_sym,
      class_name: "#{name.to_s.singularize.camelcase}"
    }

    defaults.keys.each {|key| self.send("#{key}=", options[key] ? options[key] : defaults[key])}
  end
end

module Associatable
  def assoc_options
    @assoc_options ||= {}
  end
  
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      primary_key = self.class.assoc_options[name].primary_key
      foreign_key = self.send(self.class.assoc_options[name].foreign_key)
      model_class = self.class.assoc_options[name].model_class

      model_class.where(primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    has_options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      primary_key = self.send(has_options.primary_key)
      foreign_key = has_options.foreign_key
      model_class = has_options.model_class

      model_class.where("#{foreign_key}" => primary_key)
    end
  end

end

class SQLObject
  extend Associatable
end
