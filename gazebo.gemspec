require_relative 'lib/gazebo'

Gem::Specification.new do |s|
  s.name        = 'gazebo'
  s.version     = Gazebo::VERSION
  s.date        = '2017-03-27'
  s.summary     = "A lightweight MVC framework inspired by rails"
  s.description = "A lightweight MVC framework"
  s.authors     = ["Tassos Bareiss"]
  s.email       = 'tassosbareiss@gmail.com'
  s.homepage    = 'http://github/tassosb/gazebo.git'
  s.files       = Dir["README.md", "lib/**/*"]
  s.license       = 'MIT'

  s.add_dependency 'activesupport'
  s.add_dependency 'pg'
  s.add_dependency 'rack'
  s.add_dependency 'colorize'
end
