class Token
  attr_accessor :name
  attr_reader :value
  attr_reader :file_name
  attr_reader :line

  def initialize(name, value, file_name, line)
    @name = name
    @value = value
    @file_name = file_name
    @line = line
  end
end
