require_relative 'application_controller'
require Rails.root.join 'lib/assets/data_log_endpoint'
require Rails.root.join 'lib/assets/log_parsers/carbon_black_log'

class MachinesController < ApplicationController
  include DataLogEndpoint
  
  def index
    @machines = filter Machine, search_fn: lambda {|x| search x}
  end

  # POST /machines/upload
  def insert_data
    get_log CarbonBlackLog, redirect: machines_path
  end

  private
  def search(query)
    Machine.left_outer_joins(:paper_trail)
      .where <<-SQL, q: "%#{query}%"
        TEXT(ip) like :q or host like :q or machines.user like :q
        or TEXT(paper_trails.insertion_date) like :q
      SQL
  end
end
