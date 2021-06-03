def intersperse_arrays(arrays, intersperse)
  [].tap do |interspersed|
    arrays.each { |array| interspersed.append(array, intersperse) }
    interspersed.pop
  end
end
