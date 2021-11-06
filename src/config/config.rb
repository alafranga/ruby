class Config
  # Adapted from https://stackoverflow.com/a/11137694
  def self.call(**kwargs)
    internal_hashes = {}
    kwargs.each do |key, value|
      internal_hashes[key] = value if value.is_a?(::Hash)
    end

    return OpenStruct.new kwargs if internal_hashes.empty?

    duplicate = kwargs.dup
    internal_hashes.each do |key, hash|
      duplicate[key] = call(**hash)
    end

    OpenStruct.new(duplicate)
  end

  def self.from_file(file)
    File.directory?(dir = File.dirname(file))   or (raise Error, "Directory not found: #{dir}")
    File.exist?(file)                           or (raise Error, "File not found: #{file}")
    (hash = YAML.load_file(file)).is_a?(::Hash) or (raise Error, "Expected a Hash where found: #{hash}")

    call(**hash)
  end

  # Adapted from https://stackoverflow.com/a/30225093/3077478
  def deep_merge(other)
    left, right = to_h, other.to_h

    merger = proc do |_, v1, v2|
      return v1.merge(v2, &merger) if v1.is_a?(::Hash)  && v2.is_a?(::Hash)
      return v1 | v2               if v1.is_a?(::Array) && v2.is_a?(::Array)

      [:undefined, nil, :nil].include?(v2) ? v1 : v2
    end

    left.merge(right, &merger)
  end

  def deep_merge_only_hash(other)
    left, right = to_h, other.to_h

    merger = proc do |_, v1, v2|
      return v1.merge(v2, &merger) if v1.is_a?(::Hash) && v2.is_a?(::Hash)

      [:undefined, nil, :nil].include?(v2) ? v1 : v2
    end

    left.merge(right, &merger)
  end
end
