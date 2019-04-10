require_relative 'data_log'
require Rails.root.join 'lib/assets/inet_loggable'
require 'uri_entry'
require 'whitelist'
require 'machine'

class CyberAdaptLog < DataLog
  include InetLoggable

  TIMESTAMP = /[0-9]+/
  FORMAT = /flexplan_srcip_host_#{TIMESTAMP.source}.csv/i
  GLOB_FORMAT = './flexplan_srcip_host_[0-9]*.csv'

  def initialize(file, recorded: nil)
    init_vars_before_super
    super(file, false, recorded) {|row| parse_row(row)}
    mass_insert @clean
  end

  private
  def init_vars_before_super
    @clean, @ip_lookup_table = [], {}
    @whitelist = Whitelist.select(:regex_string).map(&:regex)
  end

  def parse_row(row)
    uri = parse_uri row[1]
    return if uri.nil? || @whitelist.any? {|regex| regex.match? uri}
    queue_insert(row[0], uri, row[2], @recorded)
  end

  def parse_uri(uri)
    return nil if matches_invalid_format? uri
    return cast_ipv6(uri) || clean_uri(uri)
  end

  def matches_invalid_format?(uri)
    uri.blank? || /<hostname[>]*/.match?(uri) 
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

  def queue_insert(ip, uri, hits, paper_trail)
    begin
      @clean << [memoize_ip(ip), uri, Integer(hits), paper_trail&.id]
    rescue Exception => e
      @dirty << CSV::Row.new(
        ['ip', 'uri', 'hits', 'paper_trail' , 'error'],
        [ip, uri, hits, paper_trail, e]
      )
    end
  end

  def memoize_ip(ip)
    return @ip_lookup_table[ip] if @ip_lookup_table.key? ip
    @ip_lookup_table[ip] = upsert_dhcp_lease(ip, @recorded).id
  end
  
  def upsert_dhcp_lease(ip, paper_trail)
    lease = past_history_for_dhcp_lease ip, paper_trail.insertion_date
    return lease unless lease.nil?
    DhcpLease.create(ip: ip, paper_trail: paper_trail)
  end

  def mass_insert(primitive_2d_array)
    UriEntry.import(
      [:dhcp_lease_id, :uri, :hits, :paper_trail_id],
      primitive_2d_array
    )
  end
end
