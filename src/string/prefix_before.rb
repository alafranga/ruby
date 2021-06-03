def prefix_before(string, separator)
  return string unless (i = string.index(separator))

  string[0...i]
end
