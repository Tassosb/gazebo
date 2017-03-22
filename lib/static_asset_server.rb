class StaticAssetServer
  attr_reader :file_server, :app, :root

  def initialize(app)
    @app = app
    @root = 'demo/public'
    @file_server = FileServer.new
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path

    if servable?(path)
      res = file_server.call(env)
    else
      res = app.call(env)
    end
    res.finish
  end

  def servable?(path)
    path.match("/#{root}")
  end
end

class FileServer
  def call(env)
    res = Rack::Response.new
    file_name = requested_file_name(env)

    if File.exists?(file_name)
      serve(file_name, res)
    else
      res.status = 404
      res.write("File not found")
    end
    res
  end

  def serve(file_name, res)
    extension = File.extname(file_name)
    extension = '.json' if extension == '.map'
    content_type = Rack::Mime::MIME_TYPES[extension]

    res['Content-Type'] = content_type
    file = File.read(file_name)
    res.write(file)
  end

  def requested_file_name(env)
    req = Rack::Request.new(env)
    path = req.path
    dir = File.dirname(__FILE__)
    File.join(dir, '..', path)
  end
end
