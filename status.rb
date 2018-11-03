class Status
  attr_accessor :line
  attr_accessor :file_name

  def initialize(file_name, line = 1)
    @file_name = file_name
    @line = line
  end
end
