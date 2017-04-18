# Gazebo

A light-weight MVC framework inspired by Rails.
Check out my beat-making app built to demonstrate using this gem.
[Github](https://github.com/Tassosb/gazebo "Gazebo Github") |
[Live](http://gazebo-demo.herokuapp.com/cats "Live Link")

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

## Models and ActiveLeopard

Model files should be named the singular version of their associated table name. Add model files in `app/models/`. All model classes need to inherit from ActiveLeopard::Base.

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

The following query methods are available after inheriting from ActiveLeopard::Base. They return Relation objects and can be chained on to each other. The query that is built is only triggered when the actually query result is needed. Relation object have access to the Enumerables module.

- `::all`
- `::first`
- `::last`
- `::joins(association)`

## ActionCondor
A Controller Base Class that is combined with a custom router and asset server to handle requests and build responses.
