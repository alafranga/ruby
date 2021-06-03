def writelines(file, lines)
  ::File.write(file, "#{[*lines].join.chomp}\n")
end
