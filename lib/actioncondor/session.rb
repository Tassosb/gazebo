class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
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

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie(
      '_gazebo_app',
      path: '/',
      value: @cookie.to_json
    )
  end
end
