require "time"

module Rack
  class Spec
    module Validators
      class TypeValidator < Base
        class << self
          def patterns
            @patterns ||= Hash.new(//)
          end

          def pattern(name, pattern)
            patterns[name] = pattern
          end
        end

        register_as "type"

        pattern "boolean", /\A(?:true|false)\z/
        pattern "float", /\A-?\d+(?:\.\d+)*\z/
        pattern "integer", /\A-?\d+\z/
        pattern "iso8601", ->(value) { Time.iso8601(value) rescue false }

        def valid?
          value.nil? || pattern === value
        end

        private

        def pattern
          self.class.patterns[constraint]
        end
      end
    end
  end
end
