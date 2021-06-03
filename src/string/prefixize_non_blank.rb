def prefixize_non_blank(string, prefix, excludes: nil)
  stripped = string.strip

  return string if prefix.empty? || stripped.empty?
  return string if excludes && [*excludes].include?(stripped)

  "#{prefix}#{string}"
end
