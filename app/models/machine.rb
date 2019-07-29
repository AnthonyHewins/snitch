require_relative 'application_record'

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
  belongs_to :department, required: false

  validates_uniqueness_of :host, allow_nil: false, case_sensitive: false

  before_save do |record|
    u = record.user
    unless u.nil?
      record.user = u.empty? ? nil : u.strip.downcase
    end

    record.host = record.host.downcase.gsub('flexibleplan\\', '')
  end

  scope :search, lambda {|q|
    Machine.select('x.ip, machines.*').joins(
      "left outer join paper_trails pt on pt.id = machines.paper_trail_id
       left outer join (
         select distinct on(dhcp_leases.ip) dhcp_leases.ip, dhcp_leases.machine_id
         from dhcp_leases
         left outer join paper_trails on paper_trails.id = dhcp_leases.paper_trail_id
         order by dhcp_leases.ip, paper_trails.insertion_date desc
       ) x on x.machine_id = machines.id"
    ).where <<-SQL, q: "%#{q}%"
      machines.host like :q or machines.user like :q
      or TEXT(pt.insertion_date) like :q
      or text(x.ip) like :q
    SQL
  }
  
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
    yield(DhcpLease.left_outer_joins(:paper_trail)).limit(1).pluck(:ip).first
  end
end
