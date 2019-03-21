require_relative './data_log'
require Rails.root.join 'app/models/uri_entry'
require Rails.root.join 'app/models/whitelist'
require Rails.root.join 'app/models/machine'

class CyberAdaptLog < DataLog
  TIMESTAMP = /[0-9]+/
  FORMAT = /flexplan_srcip_host_#{TIMESTAMP.source}.csv/i
  GLOB_FORMAT = './flexplan_srcip_host_[0-9]*.csv'
  
  def initialize(file, date_override: nil, regex: nil)
    super(file, false, date_override, regex, CyberAdaptLog) {|row| parse_row(row)}
  end

  def self.create_from_timestamped_file(file)
    CyberAdaptLog.new(file, regex: TIMESTAMP)
  end

  private
  def parse_row(row)
    uri = parse_uri row[1]
    return if uri.nil? || whitelist.any? {|regex| regex.match? uri}
    add_to_list(row[0], uri, row[2], @date_override)
  end

  def whitelist
    @whitelist ||= Whitelist.select(:regex_string).map(&:regex)
  end

  def parse_uri(uri)
    return nil if matches_invalid_format? uri
    return cast_ipv6(uri) || clean_uri(uri)
  end

  def matches_invalid_format?(uri)
    /<hostname[>]*/.match? uri
  end

  def cast_ipv6(uri)
    if uri[0] == "[" # IPv6 addresses are wrapped in brackets
      matchdata = IPAddr::RE_IPV6ADDRLIKE_COMPRESSED.match(uri[1..-2])
      return matchdata[0] unless matchdata.nil?
    end
  end

  def clean_uri(uri)
    URI::regexp.match?(uri) ? uri : 'http://' + uri
  end
  
  def add_to_list(ip, uri, hits, paper_trail)
    begin
      @clean << UriEntry.create!(
        machine: Machine.find_or_create_by(ip: ip),
        uri: uri,
        hits: Integer(hits),
        paper_trail: paper_trail
      )
    rescue Exception => e
      @dirty << CSV::Row.new(
        ['ip', 'uri', 'hits', 'paper_trail' , 'error'],
        [ip, uri, hits, paper_trail, e]
      )
    end
  end
end
