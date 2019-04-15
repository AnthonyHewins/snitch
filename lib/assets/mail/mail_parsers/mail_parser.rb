module MailParser
  protected
  def parse
    raise NotImplementedError
  end

  def find_then_eat(start, stop)
    @string = kill_off_everything_before start
    end_slice = @string.index(stop)
    target_text = @string[0..(end_slice - 1)]
    @string = @string[ (end_slice + stop.length)..-1 ]
    return target_text
  end

  def kill_off_everything_before(start)
    return @string if start.nil?
    beginning_we_dont_care_about = @string.index(start) + start.length
    @string.slice beginning_we_dont_care_about..-1
  end
end
