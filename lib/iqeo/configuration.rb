module Iqeo

  module Conf

    class Configuration

      # todo: tests - init without block, with block & param, with plain block

      def initialize &block
        @items = {}
        if block_given?
         if block.arity == 1
           yield self
         else
           instance_eval &block
         end
        end
      end

      # todo: tests - with value, without value, multiple values ?, optional '=' with value ?

      def method_missing name, *value
        if value.empty?
          @items[name]
        else
          @items[name] = value.first
        end
      end

    end

  end

end

