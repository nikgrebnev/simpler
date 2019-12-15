require 'logger'

class AppLogger
  def initialize(app, **options)
    @logger = Logger.new('log/app.log')
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

#    @logger.info(env)

    @logger.info main_log_info(env, status, headers)

    [status, headers, body]
#    ret = Rack::Response.new(body, status, headers)
#    ret
  end

  private

  def main_log_info(env, status, headers)
    #Request: GET /tests?category=Backend
    #Handler: TestsController#index
    #Parameters: {'category' => 'Backend'}
    #Response: 200 OK [text/html] tests/index.html.erb
    info = "\nRequest: #{env["REQUEST_METHOD"]} #{env["REQUEST_URI"]}\n"
    info += "Handler: #{env['simpler.controller'].class}##{env['simpler.action']}\n" unless env['simpler.controller'].nil?
    info += "Parameters: #{env['simpler.params']}\n"
    info += "Response: #{status} #{status_code_by_number(status)} [#{headers["Content-Type"]}] #{env['simpler.render_path']}\n"
    info
  end

  def status_code_by_number(num)
    Rack::Utils::HTTP_STATUS_CODES[num.to_i]
  end

end