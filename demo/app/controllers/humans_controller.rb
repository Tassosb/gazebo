class HumansController < ActionCondor::Base
  def index
    @humans = Human.all
    render :index
  end

  # def show
  #   @human = Human.find(params['id'])
  #   render :show
  # end
end