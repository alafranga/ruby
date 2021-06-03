class Structable < Module
  Error = Class.new ArgumentError

  def self.call(*members, **defaults)
    new(*members, **defaults)
  end

  def self.build(required:, optional: [])
    this = self

    Class.new do
      include this.(*required, *optional)

      define_method :after_initialize do
        present!(only: required)
      end
    end
  end

  attr_reader :members, :defaults

  def initialize(*members, **defaults) # rubocop:disable Lint/MissingSuper
    @members  = [*members, *defaults.keys].uniq
    @defaults = defaults
  end

  def included(base)
    super

    members, defaults = self.members, self.defaults

    base.attr_accessor(*members)

    base.define_singleton_method(:members)  { members  }
    base.define_singleton_method(:defaults) { defaults }

    base.include InstanceMethods
    base.extend  ClassMethods
  end

  module InstanceMethods
    def initialize(**args) # rubocop:disable Lint/MissingSuper
      self.class.defaults.each do |attr, value|
        public_send "#{attr}=", value
      end

      before_initialize if respond_to? :before_initialize
      update(**args)
      after_initialize if respond_to? :after_initialize
    end

    def update(**args)
      args.each do |attr, value|
        next unless self.class.members.include? attr

        public_send("#{attr}=", value)
      end
      self
    end

    def present!(only: nil, except: nil) # rubocop:disable all
      required = if !only && !except
                   self.class.members
                 elsif only && !except
                   only
                 elsif !only && except
                   self.class.members - except
                 else
                   only - except
                 end

      return if (missings = required.reject { |member| public_send(member) }).empty?

      raise Error, "Missing attribute(s): #{missings.join(', ')}"
    end

    def to_h
      {}.tap do |h|
        self.class.members.each { |attr| h[attr] = public_send(attr) }
      end
    end
  end

  private_constant :InstanceMethods

  module ClassMethods
    def consume!(hash)
      new(**hash.slice(*members)).tap do
        members.each { |member| hash.delete(member) }
      end
    end
  end

  private_constant :ClassMethods
end
