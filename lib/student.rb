require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id = nil)
    @name, @grade, @id = name,grade,id
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
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save

    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES(?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]

    end
  end

  def self.create(name, grade)
    Student.new(name,grade).tap{|student| student.save}
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.new_from_db(row)
    # binding.pry
    self.new(row[1],row[2],row[0]).tap{|student| student.save}
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    info = DB[:conn].execute(sql, name)[0]
    # binding.pry
    self.new(info[1],info[2],info[0]).tap{|student| student}
  end



end
