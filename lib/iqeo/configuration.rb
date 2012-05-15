
require_relative "configuration/version"
require_relative "configuration/hash_with_indifferent_access"

# todo: blank slate for DSL

# Iqeo namespace

module Iqeo

  # Configuration class.
  #
  # A DSL representing configuration files.

  class Configuration

    # Returns Configuration version number.

    def self.version
      VERSION
    end

    # Creates a new Configuration instance from string.
    #
    # Content should be in Eval DSL format.

    def self.read string
      conf = self.new
      conf.instance_eval string
      conf
    end

    # Creates a new Configuration instance from filename or File/IO object.
    #
    # Content should be in Eval DSL format.

    def self.load file
      return self.read file.respond_to?(:read) ? file.read : File.read(file)
    end

    def self.new_defer_block_for_parent parent, &block
      conf = Configuration.new
      conf._parent = parent
      if block_given? && block.arity == 1
        block.call(conf)                                              # this is 'yield self' from the outside
      else
        raise "WTF! expected a block with a single parameter"
      end
      conf
    end

    def initialize default = nil, &block
      @_items = case
                  when default.kind_of?( HashWithIndifferentAccess ) then default
                  when default.kind_of?( Configuration ) then default._items
                  else HashWithIndifferentAccess.new
                end
      @_parent = nil
      if block_given?
        if block.arity == 1                                           # cannot set parent for yield blocks here as self is wrong !?
          yield self
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

    attr_accessor :_parent, :_items

    def _set key, value
      # fix: extend parenting for enumerable with configurations at arbitrary depth
      case
      when value.kind_of?( Configuration ) then value._parent = self
      when value.kind_of?( Enumerable )    then value.each { |v| v._parent = self if v.kind_of? Configuration }
      end
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
      return @_items[key] if _parent.nil?
      _parent._get key
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
      self
    end

    def _merge other
      self.dup._merge! other
    end


  end

end

