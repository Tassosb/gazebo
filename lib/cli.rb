require 'thor'

module Gazebo
  class DatabaseTasks < Thor
    desc "migrate", "run any previously unexecuted migrations"
    def migrate
      DBConnection.run_migrations
    end

    desc "seed", "seed database"
    def seed
      Gazebo.seed
    end
  end

end
