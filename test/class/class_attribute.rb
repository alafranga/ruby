# frozen_string_literal: true

module Test
  module Const
    # Copied from https://github.com/dry-rb/dry-core.  All kudos to the original authors.

    require 'set'

    # An empty array
    EMPTY_ARRAY = [].freeze
    # An empty hash
    EMPTY_HASH = {}.freeze
    # An empty list of options
    EMPTY_OPTS = {}.freeze
    # An empty set
    EMPTY_SET = ::Set.new.freeze
    # An empty string
    EMPTY_STRING = ''
    # Identity function
    IDENTITY = (->(x) { x }).freeze

    Undefined = Object.new.tap do |undefined| # rubocop:disable Metrics/BlockLength
      const_set(:Self, -> { Undefined })

      def undefined.to_s
        'Undefined'
      end

      def undefined.inspect
        'Undefined'
      end

      def undefined.default(x, y = self)
        if equal?(x)
          if equal?(y)
            yield
          else
            y
          end
        else
          x
        end
      end

      def undefined.map(value)
        if equal?(value)
          self
        else
          yield(value)
        end
      end

      def undefined.dup
        self
      end

      def undefined.clone
        self
      end

      def undefined.coalesce(*args)
        args.find(Self) { |x| !equal?(x) }
      end
    end.freeze

    def self.included(base)
      super

      constants.each do |const_name|
        base.const_set(const_name, const_get(const_name))
      end
    end
  end
  # Stolen and improved from dry-rb/dry-core
  module ClassAttribute
    module Value
      Update = Object.new.tap do |object|
        def object.call(current_value, new_value)
          raise ArgumentError, "Value must be updateable: #{new_value}" unless new_value.respond_to? :[]

          current_value.tap { new_value.each { |k, v| current_value[k.to_sym] = v } }
        end
      end.freeze

      Append = Object.new.tap do |object|
        def object.call(current_value, new_value)
          raise ArgumentError, "Value must be appendable: #{new_value}" unless new_value.respond_to? :<<

          current_value.tap { new_value.each { |v| current_value << v } }
        end
      end.freeze

      Assign = Object.new.tap do |object|
        def object.call(_, new_value)
          new_value.dup
        end
      end.freeze

      class << self
        def behave(behave, value = Const::Undefined)
          Const::Undefined.equal?(behave) ? implicit(value) : explicit(behave)
        end

        private

        # Map given symbol to relevant module
        def explicit(behave)
          const_get behave.to_s.capitalize
        rescue NameError
          raise ArgumentError, "Unrecognized behave: #{behave}"
        end

        # Deduce semantics from a value
        def implicit(value)
          require 'ostruct'
          require 'set'

          case value
          when ::Hash, ::Struct, ::OpenStruct then Update
          when ::Array, ::Set                 then Append
          else                                     Assign
          end
        end
      end
    end

    private_constant :Value

    # rubocop:disable Metrics/MethodLength,Layout/LineLength,Lint/RedundantCopDisableDirective
    def define(name, default: Const::Undefined, behave: Const::Undefined, inherit: true, instance_reader: false)
      ivar   = :"@#{name}"
      behave = Value.behave(behave, default)

      instance_variable_set(ivar, default.dup)

      mod = ::Module.new do
        define_method(name) do |new_value = Const::Undefined|
          if Const::Undefined.equal?(new_value)
            return instance_variable_defined?(ivar) ? instance_variable_get(ivar) : nil
          end

          instance_variable_set(
            ivar,
            behave.(
              instance_variable_defined?(ivar) ? instance_variable_get(ivar) : instance_variable_set(ivar, default.dup),
              new_value
            )
          )
        end

        define_method(:inherited) do |klass|
          klass.send(name, (inherit ? send(name) : default).dup)

          super(klass)
        end
      end

      extend(mod)

      define_method(name) { self.class.send(name) } if instance_reader
    end
    # rubocop:enable Metrics/MethodLength,Layout/LineLength,Lint/RedundantCopDisableDirective

    def defines(*names, behave: Const::Undefined)
      names.each { |name| define(name, behave: behave) }
    end
  end
end
