# This class defines the low-level methods to move forward and backward through
# the input. Note that all of the methods in this module are private since they
# not intended to be used directly on instances, nor even in the DSL. Instead,
# these methods will be used to create methods that compose the DSL.
module Readgex::Motion
  include Readgex::Core

private
  # Increments the position by one, and returns the character at the previous
  # position. Will raise a Readgex::EndOfInputError if the end of input is
  # reached.
  def one_forward
    raise Readgex::EndOfInputError if end_of_input?

    char = peek
    @position += 1
    char
  end

  # Decrements the position by one, and returns the character at the previous
  # position. Will raise a Readgex::BeginningOfInputError if the end of input is
  # reached.
  def one_backward
    raise Readgex::BeginningOfInputError if beginning_of_input?

    char = peek
    @position -= 1
    char
  end

  # Given a number >= 0, will move the position forward that many and return
  # the consumed characters.
  def forward(n)
    raise ArgumentError, '#forward only accepts numbers greater than 0' if n < 0

    n.times.map { one_forward }
  end

  # Given a number >= 0, will move the position backward that many and return
  # the consumed characters.
  def backward(n)
    raise ArgumentError, '#backward only accepts numbers greater than 0' if n < 0

    n.times.map { one_backward }
  end

  # Move forward while the specified block returns true. Returns all of the
  # consumed input.
  def forward_while(&block)
    raise ArgumentError, '#forward_while must be given a block' if block.nil?
    chs = []

    if block.arity == 0
      chs << one_forward while block.call
    else
      chs << one_forward while block.call(peek)
    end

    chs
  end

  # Move backward while the specified block returns true. Returns all of the
  # consumed input.
  def backward_while(&block)
    raise ArgumentError, '#backward_while must be given a block' if block.nil?
    chs = []

    if block.arity == 0
      chs << one_backward while block.call
    else
      chs << one_backward while block.call(peek)
    end

    chs
  end

  # A negative version of forward_while.
  def forward_until(&block)
    raise ArgumentError, '#forward_until must be given a block' if block.nil?
    chs = []

    if block.arity == 0
      chs << one_forward until block.call
    else
      chs << one_forward until block.call(peek)
    end

    chs
  end

  # A negative version of backward_while.
  def backward_until(&block)
    raise ArgumentError, '#backward_until must be given a block' if block.nil?
    chs = []

    if block.arity == 0
      chs << one_backward until block.call
    else
      chs << one_backward until block.call(peek)
    end

    chs
  end

  # This method missing will match any of the above methods, suffixed with a ?
  # (e.g. one_forward?, backward_until?, etc.). When the end/beginning of input
  # is reached, these methods will behave like their counterparts. However if
  # it is reached, motion is halted and the consumed input is returned.
  def method_missing(name, *args, &block)
    if name =~ /\A(?<meth>.+)\?\Z/
      meth = Regexp.last_match['meth'].to_sym
      if Readgex::Motion.private_instance_methods.include?(meth)
        begin
          original_position = @position
          send(meth, *args, &block)
        rescue Readgex::EndOfInputError, Readgex::BeginningOfInputError
          case original_position <=> @position
          when -1 then input[original_position..-1]
          when  0 then []
          when  1 then input[0..original_position].reverse
          end
        end
      else
        super
      end
    else
      super
    end
  end
end
