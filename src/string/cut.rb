def cut(string, separator)
  return string, '', false unless (i = string.index(separator))

  [string[0...i], string[i + separator.length..-1], true]
end
