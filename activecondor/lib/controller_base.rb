class ControllerBase
  attr_reader :req, :res, :params, :token, :flash


  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
    @@protect_from_forgery ||= false
  end

  def flash
    @flash ||= Flash.new(req)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response || false
  end

  # Set the response status code and header
  def redirect_to(url)
    check_for_repeat_action!
    res.status = 302
    res['location'] = url

    session.store_session(res)
    flash.store_flash(res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    check_for_repeat_action!
    res['Content-Type'] = content_type
    res.write(content)

    session.store_session(res)
    flash.store_flash(res)
    @already_built_response = true
  end

  #raise error if already_built_response
  def check_for_repeat_action!
    raise "Cannot call render/redirect twice in one action" if already_built_response?
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore[0..-("_controller".length + 1)]
    file_path = "demo/views/#{controller_name}/#{template_name}.html.erb"
    file_content = File.read(file_path)
    content = ERB.new(file_content).result(binding)

    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
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
