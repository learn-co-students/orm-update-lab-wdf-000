require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade)
    @id = nil
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id PRIMARY KEY,
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
    self.update

    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]


    end

    def self.create(name, grade)
      self.new(name, grade).save
    end

    def self.new_from_db(array)
      new_student = self.new(array[1], array[2])
      new_student.id = array[0]
      new_student
    end

    def self.find_by_name(name)
      sql = <<-SQL
        SELECT *
        FROM students
        WHERE name = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
    end

    def update
      sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.grade, self.id)

    end

end
