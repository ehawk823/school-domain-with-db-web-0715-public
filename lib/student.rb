require 'pry'

class Student
  attr_accessor :id, :name, :tagline, :github, :twitter, :blog_url, :image_url, :biography

  @@students = []
  def initialize (id=nil, name=nil, tagline=nil, github=nil, twitter=nil, blog_url=nil, image_url=nil, biography=nil)
    @id=id
    @name=name
    @tagline=tagline
    @github=github
    @twitter=twitter
    @blog_url=blog_url
    @image_url=image_url
    @biography=biography
    @@students << self
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE students ( id INTEGER PRIMARY KEY, name TEXT, tagline TEXT, github TEXT, twitter TEXT, blog_url TEXT, image_url TEXT, biography TEXT);")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students;")
  end

  def insert
    DB[:conn].execute("INSERT INTO students (name, tagline, github, twitter, blog_url, image_url, biography)
    VALUES (?,?,?,?,?,?,?);", [name, tagline, github, twitter, blog_url, image_url, biography])
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;").flatten[0]
  end

  def self.new_from_db(row)
    new_student = Student.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.tagline = row[2]
    new_student.github = row[3]
    new_student.twitter = row[4]
    new_student.blog_url = row[5]
    new_student.image_url = row[6]
    new_student.biography = row[7]
    new_student
  end

  def self.find_by_name(name)
    @@students.each { |student| return student if student.name == name }
    nil
  end

  def update
    @@students.each { |student| student.name = @name if student.id == @id }
    DB[:conn].execute("UPDATE students SET name = (?) WHERE id = (?);", [@name, @id])
  end

  def save
    if @@students.include?(self.id)
      update
    end
    insert
  end

  def persisted?
    !!id
  end

  def save
    if persisted?
      update
    else
      insert
    end
  end

end
