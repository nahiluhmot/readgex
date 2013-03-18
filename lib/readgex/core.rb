# The core Readgex module from which the rest of the heirarchy extends. This
# class defines the following attributes:
#
#   - input: The entire input, an Array that contains the input string
#            character-by-character. An Array was chosen for simplicity of
#            implementation, since it's easy to mimic an Enumerator that can
#            go forward and backward.
#
#   - last_result: A String that contains the result of the last parse.
#
#   - position: The current position of the parse.
#
#   - parser: The block that will be called upon the input. This block is
#             intended to be passed in at initialization time, but not run
#             until it actually has input to consume.
#
module Readgex::Core
  attr_accessor :input, :last_result, :position, :parser

  # Retruns true if all of the input has been consumed.
  def end_of_input?
    @position == @input.length
  end

  # Retruns true if none of the input has been consumed.
  def beginning_of_input?
    @position.nil? || @position.zero?
  end

  def with_last_result
    yield @last_result
  end

  # Returns all of the input that has been consumed thus far.
  def consumed_input
    if @position > 0
      @input[0..@position.pred]
    else
      []
    end
  end

  # Returns the current character.
  def peek
    @input[@position]
  end

  # Returns the input converted back into a String.
  def entire_input
    @input.join
  end

  # Given a string, sets the input to the String split by each character.
  def entire_input=(str)
    @input = str.split('')
  end
end
