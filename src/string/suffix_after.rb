def suffix_after(string, separator)
  return string unless (i = string.reverse.index(separator.reverse))

  string[string.length - i..-1]
end
