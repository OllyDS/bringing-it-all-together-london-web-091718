require 'pry'
require 'sqlite3'
require_relative '../config/environment.rb'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT);
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (id, name, breed)
    VALUES (?, ?, ?);
    SQL
    DB[:conn].execute(sql, self.id, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?;
    SQL
    DB[:conn].execute(sql, id)[0]
    new_from_db(id)
  end

  def self.new_from_db(row)
    Dog.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?;
    SQL
    dog = DB[:conn].execute(sql, name)[0]
    new_from_db(dog)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?;
    SQL

    value = DB[:conn].execute(sql, name, breed)[0]
    value != nil ? self.find_by_name(name) : create(name: name, breed: breed)
  end

  def update
    sql = "UPDATE dogs SET name=?, breed=? WHERE id=?"
    DB[:conn].execute(sql, self.name, self.breed ,self.id)
  end

end
