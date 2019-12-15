require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    CONTENT_TYPES = {
        :html => 'text/html',
        :plain => 'text/plain'
    }.freeze

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      send(action)

      set_default_headers

      write_response

      @response.finish
    end

    def params
#      puts "params"
#      puts "@request.env['simpler.params'] #{@request.env['simpler.params']}"
#      puts "@request.params #{@request.params}"
      @request.env['simpler.params'].merge!(@request.params)
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      add_header'Content-Type', CONTENT_TYPES[@content_type || :html]
    end

    def add_header(var,val)
      @response[var] = val
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      @render_body || View.new(@request.env).render(binding)
    end

    def render(*var_array)
      options = var_array[0]
      if options.is_a?(Hash)
        options.each do |key,val|
          case key
            when :plain
              @render_type = key
              @render_body = val
          end
        end
      else
        @request.env['simpler.template'] = options
      end
    end

    def status(status)
      @response.status = status
    end

    def content_type(type)
      @content_type = type
    end
  end
end
