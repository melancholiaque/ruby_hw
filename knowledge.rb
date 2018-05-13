def attribute(name, value = nil, &block)
  return name.each { |k, v| attribute(k, v) } if name.is_a? Hash
  class_eval do
    define_method name do
      instance_variable_get("@#{name}") ||
        instance_variable_set("@#{name}", value || instance_eval(&block))
    end

    define_method "#{name}?" do
      !instance_variable_get("@#{name}").nil?
    end

    define_method "#{name}=" do |val|
      instance_variable_set("@#{name}", val)
    end
  end
end
