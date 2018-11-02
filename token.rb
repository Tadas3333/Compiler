class Token
  attr_reader :name
  attr_reader :value
  attr_reader :line

  def initialize(name, value, line)
    @name = name
    @value = value
    @line = line
  end
end
