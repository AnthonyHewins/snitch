require_relative 'searchable'
require 'fs_isac_alert'

module FsIsacAlertSearch
  include Searchable

  def filter
    filter_by_id
  end

  private
  def filter_by_text_fields
  end
end
