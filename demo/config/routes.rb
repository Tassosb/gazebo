Gazebo::Router.draw do
  get Regexp.new("^/$"), CatsController, :go
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  get Regexp.new("/cats"), CatsController, :index
  get Regexp.new("/humans"), HumansController, :index
end
