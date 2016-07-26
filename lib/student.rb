require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id, @name, @grade = id, name, grade
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
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    Student.new(name, grade).tap(&:save)
  end

  def self.new_from_db(row)
    id, name, grade = row[0], row[1], row[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name=? LIMIT 1"
    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end
end
