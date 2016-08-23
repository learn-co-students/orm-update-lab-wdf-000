require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @id = id
    self.name = name
    self.grade = grade
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * from students where name = ?
    SQL
    new_from_db(DB[:conn].execute(sql,name)[0])
  end

  def self.new_from_db(row)
    new_student = Student.new(row[1],row[2],row[0])
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
      )
      SQL
    DB[:conn].execute(sql)
  end


  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ?
    SQL
    DB[:conn].execute(sql,self.name,self.grade)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

end
