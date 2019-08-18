require 'application_record'
require 'concerns/machine_hook'

class Machine < ApplicationRecord
  include MachineHook

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
