module MailParser
  class ParseError < Exception; end

  protected
  def parse
    raise NotImplementedError
  end

  def find_then_eat(start, stop)
    @string = kill_off_everything_before start
    end_slice = find_str(stop)
    target_text = @string[0..(end_slice - 1)]
    @string = @string[ (end_slice + stop.length)..-1 ]
    return target_text
  end

  def kill_off_everything_before(start)
    return @string if start.nil?
    beginning_we_dont_care_about = find_str(start) + start.length
    @string.slice beginning_we_dont_care_about..-1
  end

  private
  def find_str(str)
    index = @string.index(str)
    return index unless index.nil?
    raise ParseError, "wasn't able to find #{str.to_s} in #{@string[0..100].to_s}"
  end
end
