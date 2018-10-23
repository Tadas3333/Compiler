class Status
  attr_reader :line
  attr_reader :index

  def initialize
    @line = 1
    @index = 0
  end

  def next_line
    @line += 1
    @index = 0
  end

  def next_index
    @index += 1
  end
end
