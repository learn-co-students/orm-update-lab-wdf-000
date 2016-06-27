require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]  
  
  attr_reader :id
  attr_accessor :name, :grade

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARYY KEY,
      name TEXT,
      grade INTEGER
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
      SQL

    DB[:conn].execute(sql)
  end

  def save
    if @id != nil
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name,grade)
        VALUES (?,?)
        SQL

      DB[:conn].execute(sql,@name,@grade)
    
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name,grade)
    student = self.new(name,grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = self.new(row[1],row[2],row[0])
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      SQL

    result = DB[:conn].execute(sql,name)[0]
    self.new(result[1],result[2],result[0])
  end

  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?",self.name,self.grade,self.id)
  end
end
