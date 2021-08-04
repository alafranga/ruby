# Stolen and simplified from dry-rb/dry-core
module SimpleClassAttributes
  def defines(*args) # rubocop:disable Metrics/MethodLength
    mod = ::Module.new do
      args.each do |name|
        ivar = :"@#{name}"

        define_method(name) do |value = nil|
          if value
            instance_variable_set(ivar, value)
          elsif instance_variable_defined?(ivar)
            instance_variable_get(ivar)
          end
        end
      end

      define_method(:inherited) do |klass|
        args.each { |name| klass.send(name, send(name)) }

        super(klass)
      end
    end

    extend(mod)
  end
end
