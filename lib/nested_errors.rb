module NestedErrors
  def self.unflatten(hash)
    hash.each_with_object({}) do |(key, value), all|
      regex = key.to_s.include?('[') ? /\[|\]\./ : '.'
      key_parts = key.to_s.split(regex).map!(&:to_sym)
      leaf = key_parts[0...-1].inject(all) { |h, k| h[k] ||= {} }
      leaf[key_parts.last] = value
    end
  end
end
