require 'pry'
require_relative "../config/environment.rb"

class Student

	attr_accessor :name, :grade, :id
	
	def initialize(name,grade,id=nil)
		@name = name
		@grade = grade
		@id = id
	end
	
	def self.create(name,grade)
		Student.new(name,grade).save
	end

	def self.new_from_db(row)
		tmp = Student.new(row[1],row[2],row[0])
	end
	
	def self.find_by_name(name)
		row = DB[:conn].execute("SELECT * FROM students WHERE name == ?;",name).first
		Student.new_from_db(row)
	end


	def self.create_table
		DB[:conn].execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER);")
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE IF EXISTS students")
	end

	def save
		if @id
			update
		else
			DB[:conn].execute("INSERT INTO students (name,grade) VALUES ( ? , ? );",@name,@grade)
			@id = DB[:conn].execute("SELECT MAX(id) FROM students").first[0]
		end
	end

	def update
		DB[:conn].execute("UPDATE students SET name == ? , grade == ? WHERE id == ?;", @name,@grade,@id)
	end
 
end
