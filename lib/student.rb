require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade, :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
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
    # if called on an object that is already persisted
    if self.id
      # updates a record
      self.update
      # otherwise,
    else
      # saves the attributes of an instance of the Student class to the database 
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)

      # and then sets the given students 'id' attribute
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    # creates a student with two attributes, name and grade,
    student = Student.new(name, grade)
    # and saves it into the students table
    student.save
  end

  # the following method is used in another class method .find_by_name(name)
  def self.new_from_db(row)
    # creates an instance with corresponding attribute values
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    # returns an instance of student that matches the name from the DB
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
    # updates the record associated with a given instance
    sql = <<-SQL
      UPDATE students 
      SET name = ?, grade = ? 
      WHERE id = ?    
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
