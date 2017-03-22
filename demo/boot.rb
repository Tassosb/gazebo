require_relative '../lib/gazebo'

Gazebo.root = File.expand_path(File.dirname(__FILE__))

require_relative 'config/routes'

Gazebo.boot
