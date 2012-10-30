module Hashie
  class Mash < Hashie::Hash
    attr_accessor :coercion

    def []=(key, value)
      coerced_value = coercion.present? ? coercion.call(value) : value
      super(key, coerced_value)
    end

    def container(path)
      parts = path.split('.', 2)
      match = (self[parts[0].to_s] || self[parts[0].to_sym])
      if !parts[1] or match.nil?
        self
      else
        match.container(parts[1])
      end
    end
  end
end
