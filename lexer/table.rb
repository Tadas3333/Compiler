require_relative '../token'
require_relative '../status'

class Table
  def initialize
    @printed_count = 0
  end

  def table_top
    puts "ID\t|LN\t|TYPE\t\t|VALUE"
    puts "----------------------------------------"
  end

  def show(token, status)
    if token.name.length > 6
      puts "#{@printed_count}\t|#{status.line}\t|#{token.name}\t|#{token.value}"
    else
      puts "#{@printed_count}\t|#{status.line}\t|#{token.name}\t\t|#{token.value}"
    end

    @printed_count += 1
  end
end
