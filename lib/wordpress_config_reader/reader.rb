class Reader

  def self.create_with_line_array(lines)
    @lines = lines
  end

  def self.create_with_filespec(filespec)
    create_with_line_array(File.read(filespec))
  end

  def self.create_with_directory(directory)
    filespec = File.join(directory, 'wp-config.php')
    create_with_filespec(filespec)
  end

end