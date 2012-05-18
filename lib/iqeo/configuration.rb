
require_relative "configuration/version"
require_relative "configuration/hash_with_indifferent_access"

# Iqeo namespace

module Iqeo

  class BlankSlate

=begin
  instance methods to keep:
    __id__
    __send__
    object_id
  needed for operation:
    dup
    instance_eval
  needed to pass rspec tests:
    equal?
    is_a?
    kind_of?
=end

    instance_methods_to_undef = %w(
      !                     !=                      !~                         <=>
      ==                    ===                     =~                         class
      clone                 define_singleton_method display                    enum_for
      eql?                  extend                  freeze                     frozen?
      hash                  initialize_clone        initialize_dup             inspect
      instance_exec         instance_of?            instance_variable_defined? instance_variable_get
      instance_variable_set instance_variables      method                     methods
      nil?                  private_methods         protected_methods          public_method
      public_methods        public_send             respond_to?                respond_to_missing?
      send                  singleton_class         singleton_methods          taint
      tainted?              tap                     to_enum                    to_s
      trust                 untaint                 untrust                    untrusted?
    )

    instance_methods_to_undef.each do |meth|
      undef_method meth
    end

  end

  # Configuration class.
  #
  # A DSL representing configuration files.

  class Configuration < BlankSlate

    # Returns Configuration version number.

    def self.version
      Iqeo::CONFIGURATION_VERSION
    end

    # Creates a new Configuration instance from string.
    #
    # Content should be in eval DSL format.

    def self.read string
      conf = self.new
      conf.instance_eval string
      conf
    end

    # Creates a new Configuration instance from filename or File/IO object.
    #
    # Content should be in eval DSL format.

    def self.load file
      return self.read file.respond_to?(:read) ? file.read : File.read(file)
    end

    def self.new_defer_block_for_parent parent, &block
      conf = Configuration.new
      conf._parent = parent
      if block_given? && block.arity > 0
        block.call(conf)                                              # this is 'yield self' from the outside
      end
      conf
    end

    attr_accessor :_parent, :_items

    def initialize default = nil, &block
      @_items = HashWithIndifferentAccess.new
      @_parent = nil
      _merge! default if default.kind_of?( Configuration )
      if block_given?
        if block.arity > 0                                            # cannot set parent for yield block here as context is unknowable
          yield self                                                  # parent is being set in new_defer_block_for_parent
        else
          if block.binding.eval('self').kind_of?( Configuration )     # for eval block if nested configuration
            @_parent = block.binding.eval('self')                     # set parent to make inherited values available
          end                                                         # during block execution
          instance_eval &block
        end
      end
    end

    def method_missing name, *values, &block
      return @_items.send( name, *values, &block ) if @_items.respond_to? name     # @_items methods are highest priority

      name = name.to_s.chomp('=')

      if block_given?                                                 # block is a nested configuration
        if block.arity == 1                                           # yield DSL needs deferred block to set parent without binding
          return _set name, Configuration.new_defer_block_for_parent( self, &block )
        else
          return _set name, Configuration.new( &block )               # eval DSL can set parent from block binding in initialize
        end
      end

      return _get name if values.empty?                               # just get item
      return _set name, values if values.size > 1                     # set item to multiple values
      return _set name, values.first                                  # set item to single value
    end

    def _set key, value
      value._parent = self if value.kind_of?( Configuration )
      @_items[key] = value
    end
    alias []= _set

    # Retrieves value for key, indifferent storage permits key to be a string or symbol.
    #
    # If configuration is nested, searches for key recursively up to root.
    #
    # Returns nil if key does not exist.

    def _get key
      return @_items[key] unless @_items[key].nil?
      return @_items[key] if @_parent.nil?
      @_parent._get key
    end
    alias [] _get

    def _read string
      instance_eval string
    end

    def _load file
      _read file.respond_to?(:read) ? file.read : File.read(file)
    end

    def _merge! other
      @_items.merge! other._items
      @_items.values.each do |value|
        value._parent = self if value.kind_of?( Configuration )
      end
      self
    end

    def _merge other
      self.dup._merge! other
    end

    # todo: why can't :_parent= be protected ?

    protected :_parent, :_items, :_items=, :_get, :[], :_set, :[]=

  end

end


