class ShowExceptions
  attr_reader :app, :error

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue StandardError => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    res = Rack::Response.new
    file_content = File.read('lib/templates/rescue.html.erb')
    content = ERB.new(file_content).result(binding)

    res['Content-Type'] = 'text/html'
    res.status = 500
    res.write(content)
    res.finish
  end
end
