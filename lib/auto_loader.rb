module Gazebo
  LOAD_PATHS = [
    "app/models",
    "app/controllers"
  ]
end

class Object
  def self.const_missing(const)
    auto_load(const)
    Kernel.const_get(const)
  end

  def auto_load(const)
    Gazebo::LOAD_PATHS.each do |dir|
      file = File.join(Gazebo::ROOT, dir, const.to_s.underscore)

      begin
        require_relative(file)
      rescue LoadError
      end
    end
  end
end

class Module
  def const_missing(const)
    Object.const_missing(const)
  end
end
