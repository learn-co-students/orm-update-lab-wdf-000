require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  @@all = []

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

    def self.create_table
      sql = <<-SQL
          CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY, name TEXT, GRADE INTEGER)
               SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
    sql = <<-SQL
          DROP TABLE students
             SQL
    DB[:conn].execute(sql)
  end

    def update
      sql = <<-SQL
                UPDATE students  SET name = ?, grade = ?
               SQL
      DB[:conn].execute(sql, self.name, self.grade)

    end

    def save
      if self.id
        self.update
      else
      sql = <<-SQL
              INSERT INTO students (name,grade) VALUES (?,?)
               SQL
      DB[:conn].execute(sql,self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
    end

    def self.create(name, grade)
      student = self.new(name, grade)
      student.save
      student
    end

    def self.new_from_db(row)
      stud = self.new(row[1],row[2],row[0])
      stud
    end

    def self.find_by_name(name)
      sql = <<-SQL
                SELECT * FROM students where name = ?
                SQL
      DB[:conn].execute(sql,name).map do |row|
        stud = self.new_from_db(row)
      end.first
    end

end
