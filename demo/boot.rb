require_relative '../lib/gazebo'

Gazebo.root = File.expand_path(File.dirname(__FILE__))

require_relative 'app/models/cat'
require_relative 'app/models/human'
require_relative 'app/controllers/cats_controller'
require_relative 'config/routes'

Gazebo.boot
