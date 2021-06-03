module Refinements
  module String
    module Underscore
      refine ::String do
        # Stolen and adapted from ActiveSupport without acronym support
        def underscore
          return self unless /[A-Z-]|::/.match?(self)

          word = gsub('::', '/')
          word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          word.tr!('-', '_')
          word.downcase!
          word
        end
      end
    end
  end
end
