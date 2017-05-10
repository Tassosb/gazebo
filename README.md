# Gazebo

A light-weight MVC framework inspired by Rails.
Check out my beat-making app built to demonstrate using this gem.
[Github](https://github.com/Tassosb/gazebo-demo "Gazebo Github") |
[Live](http://gazebo-demo.herokuapp.com/ "Live Link")

## Installation

`gem install gazebo`

## Project Setup

You will need to create a project directory with the following structure (need to add a `gazebo new` command):

- /app_name
  - /app
    - /controllers
    - /models
    - /views
  - /config
  - /db
    - /migrations

Add `gazebo ~> '^0.1.4'` to your Gemfile.

Additionally, at the root of the project you will need a file named `config.ru` with the following code:

```
require 'gazebo'

Gazebo.root = File.expand_path(File.dirname(__FILE__))

run Gazebo.app
```

## Migrations

Files in `db/migrations/` will be read and executed as raw sql. Specify the order in which the files will be executed by prefixing each filename with a two digit number (01, 02, 03, ...). This is necessary for migrations to work as expected.

`gazebo migrate` runs any new migrations. Migrations are deemed to be new based on the presence of the filename in a 'migrations' table. At the moment there is no command to rollback migrations. Simply add new ones to reverse the changes you made.

```
#lib/activeleopard/db_connection.rb

def self.run_migration_file(file_name)
  migration_name = file_name.match(/\w+/).to_s

  return if migration_name.empty? || already_run?(migration_name)

  file = File.join(Gazebo::ROOT, "db/migrations", file_name)
  migration_sql = File.read(file)
  execute(migration_sql)

  record_migration!(migration_name)
end
```

## Models and ActiveLeopard

Model files should be named the singular version of their associated table name. Add model files in `app/models/`. All model classes need to inherit from ActiveLeopard::Base. Additionally, users need to call `::finalize!` at the end of the model class definition.

### Validations

Gazebo supports presence and uniqueness validators. The ::validates method can be invoked inside of the class definition, accepting a column_name and an options hash.

Example:
`validates :name, presence: true, uniqueness: true`

Validations are checked for upon saving. If any validations fail, `#save` will return false. Additionally, the errors will be accessible with the `#errors` method and can be displayed by `#show_errors`.

### Associations

All association creators use sensible defaults generated based on the model class name when explicit primary keys or class names are not given.

`::belongs_to(association_name, options)`
example: `belongs_to :human, foreign_key: :owner_id`

`::has_many(association_name, options)`
example: `has_many :cats, :foreign_key => :owner_id`

`has_many_through(association_name, options)`
example: `has_many_through :cats, :humans, :cats`

`has_one_through(association_name, options)`

### ActiveLeopard Query Methods

The following query methods are available after inheriting from ActiveLeopard::Base. They return Relation objects and can be chained on to each other. The query that is built is only triggered when the actually query result is needed. Relation objects have access to the Enumerables module.

- `::all`

- `::joins(association symbol or string)`
- `::select(string)`
- `::group(string)`
- `::limit(number)`
- `::from(string)`
- `::order(string)`
- `::where(string or hash)`

```
#lib/activeleopard/modules/searchable.rb

def where(*params)
  Relation.new(
    {where: WhereClause.new(params)},
    self
    )
end
```
- `::distinct`

The Relation object holds onto the query parameters inside of the `query` instance variable. Before executing the query, or when requested by the user for debugging, the Relation object calls `#as_sql` on each of the clause objects inside of the query hash to construct the sql query.
```
#lib/activeleopard/relation.rb

def as_sql
  Relation.ordered_clauses.map do |clause|
    query[clause].as_sql
  end.join(" \n ")
end
```

Rather than returning a relation object, the following methods return the found records as object(s).

- `::first`
- `::last`
- `::find(id)`
- `::find_by(string or hash)`

### CRUD Methods

- `::new(params_hash)`
- `save` ( returns true or false )
- `#valid?`
- `#destroy`
- `::destroy_all`

### Lifecycle Callback Methods

- `::after_initialize(callback_method)` (callback method is invoked in last line of initialize)

## Seeding

Add a `seeds.rb` in /db. You will have access to all the model classes you've defined when you run `bundle exec rake db:seed`.

## Routes

Routes can be defined in `config/routes.rb`. You will need to make this file yourself. Define routes within a block passed to the `Gazebo::Router.draw` method. You need to write out the path as a regular expression, as the router will use regular expression to match wildcards in the path.

Example:
```
Gazebo::Router.draw do
  get Regexp.new("^/beats"), BeatsController, :index
  delete Regexp.new("^/beats/(?<id>\\d+)$"), BeatsController, :destroy
end
```

With the second route, any number after '/beats' will show up in params under a key of 'id'.

## Controllers and ActionCondor

Controller file names should be the constantized form of the folder names in '/views'. Otherwise, ActionCondor will not be able to guess which template to render by default.

### Session

`#session` exposes a Session object which provides an interface for setting keys in an application session cookie. This could be used to implement a basic auth pattern.

### CSRF Protection

When `::protect_from_forgery` is invoked inside of a controller class definition, any non-get requests will be denied unless they carry the correct authenticity_token. authenticity_token can be sent up in forms by including a hidden input with the value given by `#form_authenticity_token`.

### Rendering and Redirecting

The main purpose of the controller base is to build up a response. You can do this easily with the following methods.

Note: a params hash will be populated from wildcards in the url, or data from request. Use `#params` to access this information.

`render(template_name)` (only renders html views at this point)

`redirect_to(url)` (paths relative to project root work fine)

`render_content(content, content_type)` (with this you can render json or text/html)

### Flash

Use `#flash` to expose a flash object. Anything set in the flash object using `[]=` will be available for the current and next req/res cycle. Key value pairs set in `#flash.now` will only be available in the current cycle.

## Serving Static Assets

Place any static assets in `app/assets/`. Most MIME types are supported by the static asset server. You will need to provide the path relative to the root of the project directory. (e.g. `app/assets/images/some_image.jpg`)
