require 'active_support/concern'

module MachineHook
  extend ActiveSupport::Concern

  included do
    belongs_to :paper_trail, required: false
    belongs_to :department, required: false

    validates_uniqueness_of :host, allow_nil: false, case_sensitive: false

    before_save do |record|
      u = record.user
      record.user = u.blank? ? nil : u.strip.downcase

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
  end
end
