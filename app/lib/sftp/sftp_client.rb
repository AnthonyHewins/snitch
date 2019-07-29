require 'net/sftp'

require 'client/searchable'
require_relative 'sftp_file'

class SftpClient
  include Searchable
  attr_accessor :host, :opts, :user

  def initialize(host, user, opts={})
    @host, @user, @opts = host, user, opts
    unless @opts.key? :keys
      @opts[:keys] = @opts.key?(:password) ? [] : ['~/.ssh/id_rsa']
    end
  end

  def pull(opts={}, &proc_filter)
    dir = opts.delete(:dir) || '.'
    Net::SFTP.start @host, @user, @opts do |conn|
      file = find(conn.dir.entries(dir), opts, &proc_filter)
      return nil if file.nil?
      return SftpFile.new(filename: file.name, text: conn.download!(file.name))
    end
  end

  private
  def filter(files, criteria, &block)
    files = filter_by_proc(filter_by_name(files, criteria), &block)
    if files.length > 1
      raise Errno::ENOENT, "found > 1 files matching criteria: #{files.map(&:name)}"
    end
    files.first
  end

  def filter_by_name(files, criteria)
    case criteria
    when String
      [files.find {|f| f.name == criteria}]
    when Regexp
      files.select {|f| criteria.match? f.name}
    when NilClass
      files
    else
      raise TypeError, "criteria must be String, Regex, or nil, got #{criteria.class}"
    end
  end
end
