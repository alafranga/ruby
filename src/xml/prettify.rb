def prettify(xml)
  out = +''
  REXML::Document.new(xml).write(output: out, indent: 2)
  out
end
