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
      DhcpLease.pluck(:ip).find_by(machine: self).last
    when DateTime, Date
      DhcpLease.pluck(:ip).left_outer_joins(:paper_trails)
        .where <<-SQL, m_id: id, date: date
          machines.id = :m_id and paper_trails.insertion_date = :date
        SQL
    when PaperTrail
      DhcpLease.select(:ip).where(machine: self, paper_trail: date)
    else
      raise TypeError
    end
  end
  
  def to_a(*cols)
    cols.empty? ? super(*CsvColumns) : super(*cols)
  end
end
