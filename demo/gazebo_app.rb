require_relative '../activeleopard/activeleopard'
require_relative '../activecondor/activecondor'
require_relative 'controllers/cats_controller'
require_relative 'models/cat'
require_relative 'models/house'
require_relative 'models/human'
require 'byebug'

router = Router.new
router.draw do
  get Regexp.new("^/$"), CatsController, :go
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  get Regexp.new("/cats"), CatsController, :index
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res#.finish
end

app = Rack::Builder.new do
  use ShowExceptions
  use Static
  run app
end.to_app

Rack::Server.start(
 app: app,
 Port: 3000
)
