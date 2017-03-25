class UsersController < ActionCondor::Base
  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.new(params['user'])
    if @user.save
      redirect_to("http://localhost:3000/cats")
    else
      flash[:errors] = @user.errors
      render :new
    end
  end

  private
  def user_params
  end
end
