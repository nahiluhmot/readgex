module Readgex
  # The base error for this gem. It's never actually instaniated, but is useful
  # for catching all internal errors.
  class ReadgexError < StandardError; end

  # Raised when the end of input is reached before a parse could finish.
  class EndOfInputError < ReadgexError; end

  # Raised when the beginning of input is reached in a rewind.
  class BeginningOfInputError < ReadgexError; end
end
