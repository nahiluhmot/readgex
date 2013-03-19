# This module defines the basic parsers used in Readgexes. Note that all of
# these methods are private since they are only supposed to be used in the DSL.
module Readgex::SimpleParser
  include Readgex::Motion

private
  # Given a character, will try to match the input against that character. Will
  # raise a Readgex::MismatchError on failure.
  def char(ch)
    if ch == one_forward
      @last_result = ch
      block_given? ? yield(ch.dup) : self
    else
      one_backward
      raise Readgex::MismatchError, "{ 'input_position': #{position}, 'expected': '#{peek}', 'got': '#{ch}' }"
    end
  end

  # Given a string, will attempt to match it against the input. Will raise a
  # Readgex::MismatchError on failure.
  def string(str)
    original_position = @position
    str.each_char { |ch| char(ch) }
    @last_result = str
    block_given? ? yield(str.dup) : self
  rescue Readgex::MismatchError => ex
    @position = original_position
    raise ex
  end

  def option(*parsers)
    success = parsers.map(&:to_proc).reduce(nil) do |output, parser|
      if output
        output
      else
        begin
          original_position = @position
          instance_eval(&parser)
          true
        rescue Readgex::ReadgexError
          @position = original_position
          nil
        end
      end
    end

    unless success.nil?
      block_given? ? yield(@last_result.dup) : self
    else
      raise Readgex::MismatchError, "{'input_position': #{position}, 'message': 'No matches in #option' }"
    end
  end

  # Defines #char? and #string?. These methods are the same as #char and
  # #string, respectively, with the exception that they will return the
  # position to it's starting point on failure, then yield nil.
  def method_missing(name, *args, &block)
    if name =~ /\A(?<method>.+)\?\Z/
      method = Regexp.last_match['method'].to_sym
      if Readgex::SimpleParser.private_instance_methods.include?(method)
        begin
          original_position = @postition
          send(method, *args, &block)
        rescue Readgex::MismatchError
          @postition = original_position
          @last_result = nil
          block.nil? ? self : block.call(nil)
        end
      else
        super
      end
    else
      super
    end
  end
end
