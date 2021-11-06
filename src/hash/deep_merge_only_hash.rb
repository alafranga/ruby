# Adapted from https://stackoverflow.com/a/30225093/3077478
def deep_merge_only_hash(left, right)
  merger = proc do |_, v1, v2|
    return v1.merge(v2, &merger) if v1.is_a?(::Hash) && v2.is_a?(::Hash)

    [:undefined, nil, :nil].include?(v2) ? v1 : v2
  end

  left.to_h.merge(right.to_h, &merger)
end

