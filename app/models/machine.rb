require_relative './application_record'

class Machine < ApplicationRecord
  has_many :uri_entries
  belongs_to :paper_trail, optional: true

  validates_uniqueness_of :ip
  validates_uniqueness_of :user, allow_nil: true, case_sensitive: false
  validates_uniqueness_of :host, allow_nil: true, case_sensitive: false

  before_save do |record|
    record.user&.downcase!
    unless record.host.nil?
      record.host.downcase!
      record.host.gsub!('flexibleplan\\', '')
    end
  end

  validate do |record|
    errors.add(:ip, "is not a valid IP address") if record.ip.nil?
  end
end
