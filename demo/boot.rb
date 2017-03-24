require_relative '../lib/gazebo'

Gazebo.root = File.expand_path(File.dirname(__FILE__))

# if ARGV[0] == 'seed'
#   Gazebo.seed!
# end

require_relative 'config/routes'

# c = Cat.new(name: "Lemons", owner_id: 4)
# c.save

Gazebo.boot
