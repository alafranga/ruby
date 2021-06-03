def expand_path(path, rootdir = nil)
  Pathname.new(::File.join(rootdir || '.', path)).cleanpath.to_s
end
