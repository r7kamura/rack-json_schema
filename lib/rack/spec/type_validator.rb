module Rack
  class Spec
    class TypeValidator
      def initialize(key, constraint)
        @key = key
        @constraint = constraint
      end

      def validate!(env)
        request = Rack::Request.new(env)
        value = request.params[@key]
        case @constraint
        when "integer"
          unless /\A-?\d+\z/ === value
            raise ValidationError, "Expected #@key to be #@constraint, but in fact #{value.inspect}"
          end
        when "number"
          /\A-?\d+(?:\.\d+)?\z/ === value
        when "string"
          true
        when "boolean"
          value == "true" || value == "false"
        end
      end
    end
  end
end
