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

  def self.seed!
    seed_file_path = File.join(Gazebo::ROOT, "db", "seeds.rb")
    $stdout.puts `ruby #{seed_file_path}`
  end

  def self.root=(root)
    const_set("ROOT", root)
  end
end
