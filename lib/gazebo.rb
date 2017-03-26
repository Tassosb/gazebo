require 'byebug'
require 'rack'

require_relative 'activeleopard/activeleopard'
require_relative 'actioncondor/actioncondor'
require_relative 'static_asset_server'
require_relative 'show_exceptions'
require_relative 'auto_loader'
require_relative 'router'

module Gazebo
  Router = Router.new

  def self.boot
    seed! if ARGV[0] == 'seed'

    fetch_routes!

    app = Proc.new do |env|
      req = Rack::Request.new(env)
      res = Rack::Response.new
      Gazebo::Router.run(req, res)
      res
    end

    app = Rack::Builder.new do
      use ShowExceptions
      use StaticAssetServer
      run app
    end.to_app

    Rack::Server.start(
     app: app,
     Port: 3000
    )
  end

  def self.root=(root)
    const_set("ROOT", root)
  end

  def self.fetch_routes!
    file = File.join(ROOT, "config/routes.rb")

    File.open(file) do |f|
      self.class_eval(f.read)
    end
  end

  def self.seed!
    file = File.join(ROOT, "db/seeds.rb")

    File.open(file) do |f|
      self.class_eval(f.read)
    end
  end
end
