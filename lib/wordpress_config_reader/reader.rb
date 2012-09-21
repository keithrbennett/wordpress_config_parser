class Reader

  attr_accessor :lines

  def self.create_with_line_array(lines)
    Reader.new(lines)
  end

  def self.create_with_filespec(filespec)
    create_with_line_array(File.readlines(filespec).map(&:chomp))
  end

  def self.create_with_directory(directory)
    filespec = File.join(directory, 'wp-config.php')
    create_with_filespec(filespec)
  end

  def initialize(lines)
    @lines = lines
  end
end