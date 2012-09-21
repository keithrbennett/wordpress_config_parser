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
    search_string = "define('#{token}'"
    matches = lines.select { |line| line[0...search_string.size] == search_string }
    matches.empty? ? nil : matches.last  # last one wins
  end


  def extract_value_from_line(line)
    # Ex: define('DB_NAME', 'abcdefgh_0001');
    # Splitting by ' will leave value as array[3]
    line.split("'")[3]
  end

  def get(token)
    line = find_def_line(token)
    line.nil? ? nil : extract_value_from_line(line)
  end

  alias [] get

  # For missing methods, assume the name is the name, converted to lower case,
  # of a defined value.  Creates the method, and adds it to the instance.
  def method_missing(method_name, *method_args)
    instance_eval("""
        def #{method_name.to_s.downcase}
          get('#{method_name.to_s.upcase}')
        end
    """)

    send(method_name)
  end

end