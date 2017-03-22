PRINT_QUERIES = true

class DBConnection
  def self.open
    create_database! unless File.exist?(db_file_name)

    @db = SQLite3::Database.new(db_file_name)

    @db.results_as_hash = true
    @db.type_translation = true

    @db
  end

  def self.create_database!
    `#{"cat '#{sql_file_name}' | sqlite3 '#{db_file_name}'"}`
  end

  def self.instance
    open if @db.nil?

    @db
  end

  def reset!
    commands = [
      "rm #{db_file_name}",
      "cat '#{sql_file_name}' | sqlite3 '#{db_file_name}'"
    ]
    commands.each { |command| `#{command}` }
  end

  def self.sql_file_name
    @sql_file ||= File.join(Gazebo::ROOT, 'db', 'gazebo_app_database.sql')
  end

  def self.db_file_name
    @db_file ||= File.join(Gazebo::ROOT, 'db', 'gazebo_app_database.db')
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
      output += " #{bind_params.inspect}"
    end

    puts output.colorize(random_color)
  end
end
