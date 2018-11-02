class Status
  attr_reader :line
  attr_reader :file_name

  def initialize(file_name)
    @line = 1
    @file_name = file_name
  end

  def next_line
    @line += 1
  end

  def set_file_name(file_name)
    @file_name = file_name
  end
end
