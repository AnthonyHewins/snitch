require_relative './application_record'

class Machine < ApplicationRecord
  CsvColumns = [
    :id,
    :user,
    :host,
    :ip,
    lambda {|machine| machine.paper_trail&.insertion_date},
    :created_at,
    :updated_at
  ]

  belongs_to :paper_trail, optional: true

  validates_uniqueness_of :user, allow_nil: true, case_sensitive: false
  validates_uniqueness_of :host, allow_nil: true, case_sensitive: false

  before_save do |record|
    record.user&.downcase!
    unless record.host.nil?
      record.host.downcase!
      record.host.gsub!('flexibleplan\\', '')
    end
  end

  def ip(date=nil)
    case date
    when NilClass
      last_known_ip
    when DateTime, Date
      ip_on_date date
    when PaperTrail
      ip_on_date date.insertion_date
    else
      raise TypeError, "date must be a datelike object, PaperTrail or nil"
    end
  end

  def to_a(*cols)
    cols.empty? ? super(*CsvColumns) : super(*cols)
  end

  private
  def last_known_ip
    pluck_ip do |q|
      q.where(machine: self)
        .order('paper_trails.insertion_date desc')
    end
  end

  def ip_on_date(date)
    pluck_ip do |q|
      q.where('paper_trails.insertion_date = :date and machine_id = :id', date: date, id: id)
    end
  end

  def pluck_ip
    yield(DhcpLease.left_outer_joins(:paper_trail))
      .limit(1).pluck(:ip).first
  end
end
