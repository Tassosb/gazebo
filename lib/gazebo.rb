require 'byebug'
require 'rack'
require 'uri'

require_relative 'activeleopard/activeleopard'
require_relative 'actioncondor/actioncondor'
require_relative 'static_asset_server'
require_relative 'show_exceptions'
require_relative 'auto_loader'
require_relative 'router'

module Gazebo
  Router = Router.new
  VERSION = "0.0.1"

  def self.app
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

    run app
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
