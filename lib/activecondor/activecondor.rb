require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require 'byebug'
require 'rack'
require 'json'

require_relative 'controller_base'
require_relative 'flash'
require_relative 'session'

class ActiveCondor
end

class ActiveCondor::Base < ControllerBase
end
