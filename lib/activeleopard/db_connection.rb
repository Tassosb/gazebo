require 'pg'
PRINT_QUERIES = true

class DBConnection
  def self.open
    if ENV['DATABASE_URL']
      self.open_production
    else
      self.open_development
    end
    run_migrations
  end

  def self.open_production
    uri = URI.parse(ENV['DATABASE_URL'])

    @db = PG::Connection.new(
      user: uri.user,
      password: uri.password,
      host: uri.host,
      port: uri.port,
      dbname: uri.path[1..-1]
    )
  end

  def self.open_development
    begin
      @db = PG::Connection.open(dbname: self.database_name)
    rescue PG::ConnectionBad => e
      create_database!
      retry
    end

    @db
  end

  def self.ensure_migrations_table!
    begin
      instance.exec("SELECT * FROM migrations")
    rescue PG::UndefinedTable
      instance.exec(<<-SQL)
        CREATE TABLE MIGRATIONS(
          ID SERIAL PRIMARY KEY NOT NULL,
          NAME CHAR(50) NOT NULL,
          CREATED_AT CHAR(50) NOT NULL
        )
      SQL
    end
  end

  def self.run_migrations
    ensure_migrations_table!
    migrations = Dir.entries("db/migrations").reject { |fname| fname.start_with?('.') }
    migrations.sort_by! { |fname| Integer(fname[0..1]) }

    migrations.each do |file_name|
      migration_name = file_name.match(/\w+/).to_s

      next if migration_name.empty? || already_run?(migration_name)

      file = File.join(Gazebo::ROOT, "db/migrations", file_name)
      migration_sql = File.read(file)

      instance.exec(migration_sql)

      record_migration!(migration_name)
    end
  end

  def self.record_migration!(migration_name)
    time = Time.new.strftime("%Y%m%dT%H%M")
    here_doc = <<-SQL
      INSERT INTO
        migrations (name, created_at)
      VALUES
       ($1, $2)
    SQL

    @db.exec(here_doc, [migration_name, time])
  end

  def self.already_run?(migration_name)
    res = @db.exec(<<-SQL, [migration_name]).first
      SELECT *
      FROM migrations
      WHERE name = $1
    SQL

    !!res
  end

  def self.create_database!
    master_conn = PG::Connection.connect(dbname: 'postgres')
    master_conn.exec("CREATE DATABASE #{database_name}")
  end

  def self.database_name
    Gazebo::ROOT.split('/').last.gsub("-", "_") + '_development'
  end

  def self.instance
    open if @db.nil?

    @db
  end

  def self.execute(*args)
    print_query(*args)
    instance.exec(*args)
  end

  def self.async_exec(*args)
    print_query(*args)
    instance.send_query(*args)
  end

  def self.get_first_row(*args)
    print_query(*args)
    instance.exec(*args).first
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
