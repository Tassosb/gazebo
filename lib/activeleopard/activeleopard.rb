require 'active_support/inflector'
require 'colorize'
require 'sqlite3'
require 'pg'

require_relative 'query_clauses/all_clauses'
require_relative 'modules/associatable'
require_relative 'modules/validatable'
require_relative 'modules/searchable'
require_relative 'assoc_options'
require_relative 'db_connection'
require_relative 'sql_object'
require_relative 'relation'
require_relative 'errors'

class ActiveLeopard
end

class ActiveLeopard::Base < SQLObject
  extend Associatable
  extend Searchable
  extend Validatable
end
