class Session
  attr_reader :cookie

  def initialize(req)
    app_cookie = req.cookies['_gazebo_app']

    @cookie = app_cookie ? JSON.parse(app_cookie) : {}
  end

  def [](key)
    @cookie[key.to_s]
  end

  def []=(key, val)
    @cookie[key.to_s] = val
  end

  def store_session(res)
    res.set_cookie(
      '_gazebo_app',
      path: '/',
      value: @cookie.to_json
    )
  end
end
