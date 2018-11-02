class Status
  attr_reader :line
  attr_reader :index
  attr_reader :file_name

  def initialize(file_name)
    @line = 1
    @index = 0
    @file_name = file_name
  end

  def next_line
    @line += 1
    @index = 0
  end

  def next_index
    @index += 1
  end

  def set_file_name(file_name)
    @file_name = file_name
  end
end
