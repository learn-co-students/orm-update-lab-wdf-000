require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name, @grade, @id = name, grade, id
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
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
    if(self.id)
      self.update
    else
      sql = <<-SQL
        INSERT INTO students(name, grade)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, name, grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student_obj = self.new(name, grade)
    student_obj.save
    student_obj
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]

    student_obj = self.new(name, grade, id)
    student_obj
  end

  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM students
      WHERE name = ?
      SQL
    DB[:conn].execute(sql, name).collect do |row|
      self.new_from_db(row)
    end.first
  end
 
end
