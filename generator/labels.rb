
class Generator
  #####################################################
  # Typical Labels
  def place_label
    @code_index
  end

  def place_missing_label
    @label_index += 1
    return "@#{@label_index}"
  end

  def replace_missing_label(label, with_label)
    @code.each.with_index(1) { |b, indx|
      if b == label
        @code[indx-1] = with_label
        break
      end
    }
  end

  #####################################################
  # Call Labels
  def label_function(function_name)
    @functions << GenFunction.new(function_name, @code_index)
  end

  def place_missing_call_label(function_name)
    return "!#{function_name}"
  end

  def replace_missing_call_labels
    @code.each.with_index(1) { |b, indx|
      cop = b.clone
      if cop.is_a?(String) && cop[0] == "!"
        cop[0] = ''
        @functions.each { |func|
          if func.name == cop
            @code[indx-1] = func.adress
          end
        }
      end
    }
  end

  #####################################################
  # While Labels
  def place_while_start_label
    new_while_id = @whiles.size
    @whiles << GenWhile.new(new_while_id, @code_index)
    return @code_index
  end

  def get_while_start_label
    return @whiles.last.start_adress
  end

  def place_missing_while_end_label
    return "##{@whiles.last.id}"
  end

  def replace_missing_while_end_labels(with_label)
    @code.each.with_index(1) { |b, indx|
      cop = b.clone
      if cop.is_a?(String) && cop[0] == "#"
        cop[0] = ''
        if cop.to_i == @whiles.last.id
          @code[indx-1] = with_label
        end
      end
    }

    @whiles.pop
  end
end
