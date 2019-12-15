module Simpler
  class Router
    class Route

      PARAMS_REGEXP = /\/:(.+?)(?:\/|$)/

      attr_reader :controller, :action, :params

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
        @params = {}
        @path_regexp = create_regexp(@path)
      end

      def match?(method, path)
        @method == method && parse_path(path)
      end

      private

      def create_regexp(path)
        path.gsub(PARAMS_REGEXP, '\/(?<\1>.+)') + '$'
      end

      def parse_path(path)
        match = path.match(@path_regexp)
        return false if match.nil?

        match.named_captures.each do |k, v|
          @params[k.to_sym] = v
        end
      end
    end
  end
end
