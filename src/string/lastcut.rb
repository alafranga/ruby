def lastcut(string, separator)
  return string, '', false unless (i = string.reverse.index(separator.reverse))

  [string[0...string.length - i - separator.length], string[string.length - i..-1], true]
end
