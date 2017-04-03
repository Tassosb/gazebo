class Flash
  def initialize(req)
    @flash = {}

    app_cookie = req.cookies['_gazebo_app_flash']

    @flash_now = app_cookie ? JSON.parse(app_cookie) : {}
  end

  def now
    @flash_now
  end

  def [](key)
    @flash[key.to_s] || @flash_now[key.to_s] || @flash_now[key]
  end

  def []=(key, val)
    @flash[key.to_s] = val
  end

  def store_flash(res)
    res.set_cookie(
      '_gazebo_app_flash',
      path: '/',
      value: @flash.to_json
    )
  end
end
