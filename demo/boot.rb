require_relative '../lib/gazebo'

Gazebo.root = File.expand_path(File.dirname(__FILE__))

if ARGV[0] == 'seed'
  Gazebo.seed!
end

require_relative 'config/routes'

Gazebo.boot
