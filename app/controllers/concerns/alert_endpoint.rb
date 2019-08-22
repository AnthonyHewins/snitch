require_relative 'reportable_endpoint'

module AlertEndpoint
  include ReportableEndpoint
  extend ActiveSupport::Concern

  def boolean_update(redirect, record, *fields)
    update_hash = extract_update_data fields
    record.update update_hash
    flash[:info] = build_flash_message update_hash, record
    redirect_to redirect
  end

  private
  def extract_update_data(fields)
    update_hash = {}
    fields.select {|i| params.key? i}
      .each {|i| update_hash[i] = truthy(i)}
    update_hash
  end

  def build_flash_message(hash, record)
    id = record.id
    hash.map do |k,v|
      "Updated alert ID##{id}'s #{k} value to #{v}"
    end
  end

  def truthy(sym)
    val = params[sym].strip.downcase
    val == "true" || val == "on" || val == "1"
  end
end
