module WordpressConfigParser
class Parser

  attr_accessor :lines


  def initialize(filespec_or_array)

    @cache = {}

    error_message = "WCParser constructor must be passed an array of lines, " +
        "a config filespec, or a directory name that contains a wp-config.php file."

    @lines = case filespec_or_array

      when Array
        filespec_or_array

      when String  # can be the config filespec or its directory
        filespec = filespec_or_array

        if File.directory?(filespec)
          filespec = File.join(filespec, 'wp-config.php')
        end

        unless File.file?(filespec)
          raise ArgumentError.new("File '#{filespec}' does not exist.  #{error_message}")
        end

        File.readlines(filespec).map(&:chomp)

      else  # error: neither array nor string
        raise ArgumentError.new(error_message)
    end
  end


  def get(token)

    hash_key = token.to_s.downcase.to_sym

    @cache[hash_key] ||= begin
      config_file_key = token.to_s.upcase
      line = find_def_line(config_file_key)
      line.nil? ? nil : extract_value_from_line(line)   # Note: cache will contain any invalid keys requested
    end
  end


  def has_key?(key)
    !! get(key)
  end


  alias [] get

  # For missing methods, assume the method_name is the name or symbol
  # of a defined value's key.  The key is looked up, and if it exists,
  # its corresponding value is returned; otherwise, super's
  # method_missing is called.
  def method_missing(method_name, *method_args)
    get(method_name) || super.method_missing(method_name, *method_args)
  end


  # Gets *last* matching def line's value, or nil if not found.
  def find_def_line(token)
    search_string = "define('#{token}'"
    lines.reverse.detect { |line| line.start_with?(search_string) }
  end


  def extract_value_from_line(line)
    # Ex: define('DB_NAME', 'abcdefgh_0001');
    # Splitting by ' will leave value as array[3]
    line.split("'")[3]
  end

  private :find_def_line, :extract_value_from_line

end
end
