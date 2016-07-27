require 'pry'
require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]  
  
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
      SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM Students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE Students
      SET name = ?, grade = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(record)
    new_student_id = record[0]
    new_student_name = record[1]
    new_student_grade = record[2]
    new_student = self.new(new_student_id, new_student_name, new_student_grade)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM Students
      WHERE name = ?
      SQL
    DB[:conn].execute(sql, name).map do |record|
      self.new_from_db(record)
    end.first
  end

end
