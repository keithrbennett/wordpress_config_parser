class WCReader

  attr_accessor :lines

  def initialize(filespec_or_array)
    case filespec_or_array

      when Array
        @lines = filespec_or_array

      when String
        filespec = filespec_or_array
        unless File.exists?(filespec)
          raise "File/directory '#{filespec}' does not exist."
        end

        if File.directory?(filespec)
          filespec = File.join(filespec, 'wp-config.php')
          unless File.exists?(filespec)
            raise "File '#{filespec}' does not exist."
          end
        end

        @lines = File.readlines(filespec).map(&:chomp)
    end

    @cache = {}
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

    hash_key = token.to_s.downcase.to_sym

    if @cache.has_key?(hash_key)
      value = @cache[hash_key]
    else
      config_file_key = token.to_s.upcase
      line = find_def_line(config_file_key)
      value = (line.nil? ? nil : extract_value_from_line(line))
      @cache[hash_key] = value # Note: cache will contain any invalid keys requested
    end
    value
  end


  def has_key?(key)
    !! get(key)
  end


  alias [] get

  # For missing methods, assume the method_name is the name or symbol
  # of a defined value's key.  If the key exists in the config file,
  # a method is created and that value returned.  Otherwise, super's
  # method_missing will be called.
  def method_missing(method_name, *method_args)

    value = get(method_name)

    if value.nil?
      super.method_missing(method_name, *method_args)
    else
      instance_eval("""
          def #{method_name.to_s.downcase}
            get('#{method_name.to_s.upcase}')
          end
      """)
    end

    value
  end

end