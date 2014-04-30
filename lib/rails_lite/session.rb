require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    session_cookie = req.cookies.find do |cookie|
      cookie.name == '_rails_lite_app'
    end

    if session_cookie
      @session_cookie_content = JSON.parse(session_cookie.value)
    else
      @session_cookie_content = {}
    end
  end

  def [](key)
    @session_cookie_content[ key ]
  end

  def []=(key, val)
    @session_cookie_content[ key ] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    session = WEBrick::Cookie.new('_rails_lite_app',
                                  @session_cookie_content.to_json)
    res.cookies << session
  end
end
