class Reader

  attr_accessor :lines

  def self.create_with_line_array(lines = [])
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

  # Ex: define('DB_NAME', 'abcdefgh_0001');
  def find_def_line(token)
    search_string = "define('#{token}',"
    regexp = Regexp.new('^' + search_string)
    matches = lines.grep(regexp)
    puts "Found #{matches.size} matches."
    matches.empty? ? nil : matches.last  # last one wins
  end


  def extract_value_from_line(line)
    # Ex: define('DB_NAME', 'abcdefgh_0001');
    # Splitting by ' will leave value as array[3]
    line.split("'")[3]
  end

  def userid

  end
end