require 'concerns/fs_isac_alert_hook'

require 'mail/mail_clients/fs_isac_mail_client'
require 'mail/mail_parsers/fs_isac_mail_parser'

class FsIsacAlert < ApplicationRecord
  include FsIsacAlertHook

  def self.create_from_exchange
    init_email_vars

    FsIsacMailClient.new.get_missing([]).each do |email|
      hash = try_parse(email.body)
      next if hash.nil? || @db_ids.include?(hash[:tracking_id])
      insert hash
    end

    @errors
  end

  class << self
    private
    def try_parse(str)
      begin
        @parser.parse str
      rescue Exception => e
        @errors << [e, str]
        nil
      end
    end

    def init_email_vars
      @db_ids = Set.new FsIsacAlert.pluck(:tracking_id)
      @parser = FsIsacMailParser.new
      @ignore = FsIsacIgnore.all_regexps
      @errors = []
    end

    def insert(hash)
      hash[:applies] = false if @ignore.any? {|i| i.match? hash[:title]}
      FsIsacAlert.create hash
    end
  end
end
