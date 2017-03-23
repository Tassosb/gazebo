class CatsController < ActionCondor::Base
  def go
    render_content("Hello from the controller", "text/html")
  end

  def index
    @cats = Cat.all
    render :index
  end

  def show
    @cat = Cat.find(params['id'])
    render :show
  end
end
