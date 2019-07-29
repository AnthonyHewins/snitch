require_relative 'mail_parser'

class MsIsacBlacklistParser
  include MailParser
  include ActionView::Helpers::SanitizeHelper

  attr_reader :ips, :domains

  def initialize(str=nil)
    @string, @ips, @domains = str, [], []
  end

  def parse(str=@string)
    @string = str[ str.index("Threat Indicators:")..-1 ]
    list = drop_escape_chars_and_split find_then_eat("<p>", "</td>")
    split_into_domains_and_ips(list)
  end

  private
  def drop_escape_chars_and_split(raw_html)
    strip_tags(raw_html.gsub(/[\[|\]]+/, '')).split(/[\s]+/)
  end

  def split_into_domains_and_ips(list)
    list.each do |item|
      begin
        @ips << IPAddr.new(item)
      rescue IPAddr::InvalidAddressError
        @domains << item
      end
    end
  end
end
