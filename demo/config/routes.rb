Gazebo::Router.draw do
  get Regexp.new("^/$"), CatsController, :go
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  get Regexp.new("/cats"), CatsController, :index
end
