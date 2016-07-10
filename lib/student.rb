require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end
  def self.create_table
    sql = <<-SQL
	CREATE TABLE
	IF NOT EXISTS students
	  (id INTEGER PRIMARY KEY,
	  name TEXT,
	  grade TEXT);
      SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE students;")
  end
  def self.create(name, grade)
    self.new(name, grade).save
    DB[:conn].execute("SELECT * FROM students WHERE id=last_insert_rowid();")
  end
  def self.new_from_db(row)
    student = Student.new(row[1], row[2])
    student.id = row[0]
    student
  end
  def self.find_by_name(name)
    sql = <<-SQL
	SELECT * FROM students
	WHERE name = ?;
      SQL
    self.new_from_db(DB[:conn].execute(sql,name)[0])
  end
  def save
    if @id
      sql = <<-SQL
	  UPDATE students
	  SET name=?, grade=?
	  WHERE id=?;
	SQL
      DB[:conn].execute(sql, @name, @grade, @id)
    else
      sql = <<-SQL
	 INSERT INTO students (name, grade)
	  VALUES (?, ?);
	SQL
      DB[:conn].execute(sql, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end
  end
  def update
    self.save
  end
end
