# https://rosettacode.org/wiki/Entropy#Ruby
def entropy(string)
  string
    .each_char
    .group_by(&:to_s)
    .values
    .map { |x| x.length / string.length.to_f }
    .reduce(0) { |e, x| e - x * Math.log2(x) }
end
