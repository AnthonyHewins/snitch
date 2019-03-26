require_relative 'application_controller'
require Rails.root.join 'lib/assets/data_log_endpoint'
require Rails.root.join 'lib/assets/log_parsers/whitelist_log'

class WhitelistsController < ApplicationController
  include DataLogEndpoint
  
  def index
    @whitelists = filter Whitelist, search_fn: lambda {|x| search x}
  end

  # POST /whitelists/upload
  def insert_data
    get_log WhitelistLog, redirect: whitelists_path
  end

  private
  def search(query)
    Whitelist.left_outer_joins(:paper_trail)
      .where <<-SQL, q: "%#{query}%"
        regex_string like :q or TEXT(paper_trails.insertion_date) like :q
      SQL
  end
end
