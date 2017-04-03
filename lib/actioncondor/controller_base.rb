class ControllerBase
  attr_reader :req, :res, :params, :token, :flash


  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
    @@protect_from_forgery ||= false
  end

  def flash
    @flash ||= Flash.new(req)
  end

  def already_built_response?
    @already_built_response || false
  end

  def redirect_to(url)
    check_for_repeat_action!
    res.status = 302
    res['location'] = url

    session.store_session(res)
    flash.store_flash(res)
    @already_built_response = true
  end

  def render_content(content, content_type)
    check_for_repeat_action!
    res['Content-Type'] = content_type
    res.write(content)

    session.store_session(res)
    flash.store_flash(res)
    @already_built_response = true
  end

  #change to custom doubleRender error
  def check_for_repeat_action!
    raise "Cannot call render/redirect twice in one action" if already_built_response?
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore[0..-("_controller".length + 1)]
    file_path = "app/views/#{controller_name}/#{template_name}.html.erb"
    file_content = File.read(file_path)

    application = File.read("app/views/layout/application.html.erb")
    application.sub!(/__YIELD__/, file_content)

    content = ERB.new(application).result(binding)
    render_content(content, 'text/html')
  end

  def session
    @session ||= Session.new(req)
  end

  def invoke_action(name)
    if protect_from_forgery? && req.request_method != 'GET'
      check_authenticity_token
    else
      form_authenticity_token
    end

    send(name)
    render(name) unless already_built_response?
  end

  def protect_from_forgery?
    @@protect_from_forgery
  end

  def check_authenticity_token
    cookie = req.cookies['authenticity_token']
    unless cookie && cookie == params['authenticity_token']
      raise "Invalid authenticity token"
    end
  end

  def form_authenticity_token
    @token ||= generate_authenticity_token
    res.set_cookie(
      'authenticity_token',
      path: '/',
      value: token
    )

    @token
  end

  def generate_authenticity_token
    SecureRandom.urlsafe_base64(16)
  end
end
