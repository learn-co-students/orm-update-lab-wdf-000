require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :grade, :id


  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (?, ?);
    SQL

    if id != nil
      update
    else
      DB[:conn].execute(sql, name, grade)
      @id = DB[:conn].execute("SELECT id FROM students WHERE name = ?", name)[0][0]
    end
  end

  def self.create(name, grade)
    created_student = Student.new(name, grade).save
    created_student
  end

  def self.new_from_db(row)
    new_student = Student.new(row[1], row[2])
    new_student.id = row[0]
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)
    new_student = new_from_db(row[0])
  end

  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, grade, id)
  end





end
