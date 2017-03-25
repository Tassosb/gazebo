class SessionsController < ApplicationController
  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.find_by_credentials(
      params['user']['username'],
      params['user']['password']
    )

    if @user
      log_in!(@user)
      redirect_to("http://localhost:3000/cats")
    else
      flash[:errors] = ["Invalid Credentials"]
      @user = User.new(
        username: params['user']['username']
      )
      render :new
    end
  end

  def log_in!(user)
    debugger
    session[:session_token] = user.reset_session_token!
  end
end
