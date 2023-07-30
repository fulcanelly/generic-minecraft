module Tools
  def self._deep_transform_values_in_object(object, &block)
    case object
    when Hash
      object.transform_values { |value| _deep_transform_values_in_object(value, &block) }
    when Array
      object.map { |e| _deep_transform_values_in_object(e, &block) }
    else
      yield(object)
    end
  end

  def self._deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = _deep_transform_keys_in_object(value, &block)
      end
    when Array
      object.map { |e| _deep_transform_keys_in_object(e, &block) }
    else
      object
    end
  end
end

class Hash
  def deep_stringify_keys
    Tools._deep_transform_keys_in_object(self) do
      _1.to_s
    end
  end

  def deep_stringify_sym_values
    Tools._deep_transform_values_in_object(self) do
      if _1.is_a? Symbol
        _1.to_s
      else
        _1
      end
    end
  end

  def deep_symbolize_keys
    Tools._deep_transform_keys_in_object(self) do
      _1.to_sym
    end
  end
end
