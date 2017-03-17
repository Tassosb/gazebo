require 'sqlite3'
require 'colorize'

PRINT_QUERIES = true
# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
ROOT_FOLDER = File.join(File.dirname(__FILE__), '..')
CATS_SQL_FILE = File.join(ROOT_FOLDER, 'cats.sql')
CATS_DB_FILE = File.join(ROOT_FOLDER, 'cats.db')

class DBConnection
  def self.open(db_file_name)
    @db = SQLite3::Database.new(db_file_name)
    @db.results_as_hash = true
    @db.type_translation = true

    @db
  end

  def self.reset
    commands = [
      "rm '#{CATS_DB_FILE}'",
      "cat '#{CATS_SQL_FILE}' | sqlite3 '#{CATS_DB_FILE}'"
    ]

    commands.each { |command| `#{command}` }
    DBConnection.open(CATS_DB_FILE)
  end

  def self.instance
    reset if @db.nil?

    @db
  end

  def self.execute(*args)
    print_query(*args)
    instance.execute(*args)
  end

  def self.execute2(*args)
    print_query(*args)
    instance.execute2(*args)
  end

  def self.get_first_row(*args)
    print_query(*args)
    instance.get_first_row(*args)
  end

  def self.last_insert_row_id
    instance.last_insert_row_id
  end

  private

  def self.random_color
    [:blue, :light_blue, :red, :green, :yellow].sample
  end

  def self.print_query(query, bind_params = [])
    return unless PRINT_QUERIES

    output = query.gsub(/\s+/, ' ')
    unless bind_params.empty?
      output += bind_params.inspect
    end

    puts output.colorize(random_color)
  end
end
