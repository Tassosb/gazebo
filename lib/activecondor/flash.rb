class Flash
  def initialize(req)
    @flash = {}

    app_cookie = req.cookies['_rails_lite_app_flash']

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

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
    res.set_cookie(
      '_rails_lite_app_flash',
      path: '/',
      value: @flash.to_json
    )
  end
end
