require Rails.root.join 'lib/assets/mail/mail_parsers/cyber_adapt_mail_parser'

class CyberAdaptAlert < ApplicationRecord
  CsvColumns = CyberAdaptAlert.column_names.map &:to_sym

  validates :alert_id,
            uniqueness: true,
            inclusion: {in: 0..2147483647},
            presence: true

  validates :alert, presence: true
  validates :msg, presence: true
  validates :src_ip, presence: true
  validates :dst_ip, presence: true
  validates :alert_timestamp, presence: true

  validates :src_port, inclusion: {in: 0..65535}, presence: true
  validates :dst_port, inclusion: {in: 0..65535}, presence: true

  before_save do |record|
    bad_chars = /&quot;|,/
    record.msg   = record.msg.squish.gsub(bad_chars, '')
    record.alert = record.alert.gsub(bad_chars, ' ').squish
  end

  scope :search, lambda {|q|
    CyberAdaptAlert.where <<-SQL, q: "%#{q}%"
      msg like :q
      or TEXT(alert_id) like :q
      or TEXT(alert_timestamp) like :q
      or TEXT(src_ip) like :q
      or TEXT(dst_ip) like :q
      or TEXT(src_port) like :q
      or TEXT(dst_port) like :q
    SQL
  }
  
  def self.create_from_email(email)
    case email
    when String
    when Viewpoint::EWS::Types::Message
      email = email.body
    else
      raise TypeError, "email must be String or Viewpoint::EWS::Types::Message"
    end
    CyberAdaptAlert.find_or_create_by CyberAdaptMailParser.new(email).parse
  end
end
