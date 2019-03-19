require 'net/sftp'

require_relative '../log_parsers/cyber_adapt_log'
require_relative './sftp_file'

class SftpClient
  attr_accessor :host, :opts, :user

  def initialize(host, user, opts={})
    @host, @user, @opts = host, user, opts
    unless @opts.key? :keys
      @opts[:keys] = @opts.key?(:password) ? [] : ['~/.ssh/id_rsa']
    end
  end

  def pull(arg=nil, dir='.', &proc_filter)
    Net::SFTP.start @host, @user, @opts do |conn|
      file = filter conn.dir.entries(dir), arg, &proc_filter
      return nil if file.nil?
      return SftpFile.new(
               filename: file.name,
               text: conn.download!(file.name)
             )
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

  def filter_by_proc(files, &block)
    return files if block.nil?
    case block.arity
    when 1
      # Caller wants entries to satisfy certain properties
      files.select &block
    when 2
      # Caller wants to use comparable interface. Do iff length >= 2,
      # so the caller's logic can immediately go to the inductive case.
      files.length < 2 ? files : [files.inject(&block)]
    else
      raise ArgumentError, "arity mismatch for supplied lambda (accepts 1-2 args)"
    end
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
