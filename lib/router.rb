class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    return false if (pattern =~ req.path).nil?

    req_method = req.params["_method"] || req.request_method

    req_method.upcase == http_method.to_s.upcase
  end

  def run(req, res)
    matched_params = pattern.match(req.path)

    params = {}
    matched_params.names.each do |param_key|
      params[param_key] = matched_params[param_key]
    end

    controller_class.new(req, res, params).invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def run(req, res)
    matched_route = match(req)

    if matched_route
      res.status = 200
      matched_route.run(req, res)
    else
      res.status = 404
    end
  end

  private
  def match(req)
    routes.find { |route| route.matches?(req) }
  end

  def add_route(pattern, method, controller_class, action_name)
    route = Route.new(pattern, method, controller_class, action_name)
    @routes << route
  end
end
