module Rack
  class Spec
    class QueryParametersValidator
      def initialize(document)
        @document = document
      end

      def validate!(env)
        parameters = @document.reach("endpoints", env["PATH_INFO"], env["REQUEST_METHOD"], "queryParameters") || {}
        parameters.each do |key, hash|
          hash.each do |type, constraint|
            ValidatorFactory.build(key, type, constraint).validate!(env)
          end
        end
      end
    end
  end
end
