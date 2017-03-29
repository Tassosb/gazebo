require_relative 'lib/gazebo'

Gem::Specification.new do |s|
  s.name        = 'gazebo'
  s.version     = Gazebo::VERSION
  s.date        = '2017-03-27'
  s.summary     = "A lightweight MVC framework inspired by rails"
  s.description = "A lightweight MVC framework"
  s.authors     = ["Tassos Bareiss"]
  s.email       = 'tassosbareiss@gmail.com'
  s.homepage    = 'https://github.com/Tassosb/gazebo'
  s.files       = Dir["README.md", "lib/**/*"]
  s.license       = 'MIT'

  s.add_dependency 'activesupport', '~> 5.0'
  s.add_dependency 'pg', '~> 0.18.4'
  s.add_dependency 'rack', '~> 1.6', '>= 1.6.4'
  s.add_dependency 'colorize', '~> 0.8.1'
end
