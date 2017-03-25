class ApplicationController < ActionCondor::Base

  def current_user
    debugger
    @current_user ||= User.find_by(session_token: session[:session_token])
  end



end
