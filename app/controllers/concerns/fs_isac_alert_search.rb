require_relative 'searchable'
require 'fs_isac_alert'

module FsIsacAlertSearch
  include Searchable

  def filter
    filter_by_fs_isac_metadata(
      filter_by_timestamp(
        filter_based_on_applicability(
          filter_by_id(filter_by_alert)
        )
      )
    )
  end

  private
  def filter_by_alert
    filter_by_indirect_alert_data(
      filter_by_direct_alert_data(FsIsacAlert.all)
    )
  end

  def filter_based_on_applicability(q)
    filter_by_severity( check_if_affects(q) )
  end

  def check_if_affects(q)
    r, a = bool_check(:resolved), bool_check(:applies)
    q = q.where('resolved is ?', r) unless r.nil?
    q = q.where('applies is ?', a) unless a.nil?
    q
  end

  def filter_by_severity(q)
    s_start, s_end = params[:severity_start], params[:severity_end]
    q = q.where('severity >= ?', s_start) unless s_start.blank?
    q = q.where('severity <= ?', s_end) unless s_end.blank?
    q
  end

  def filter_by_direct_alert_data(q)
    a, p, c = params[:alert], params[:affected_products], params[:corrective_action]
    q = q.where('alert ilike ?', "%#{a}%") unless a.blank?
    q = q.where('affected_products ilike ?', "%#{p}%") unless p.blank?
    q = q.where('corrective_action ilike ?', "%#{c}%") unless c.blank?
    q
  end

  def filter_by_indirect_alert_data(q)
    t, s, c = params[:title], params[:sources], params[:comment]
    q = q.where('title ilike ?', "%#{t}%") unless t.blank?
    q = q.where('sources ilike ?', "%#{s}%") unless s.blank?
    q = q.where('comment ilike ?', "%#{c}%") unless c.blank?
    q
  end

  def filter_by_fs_isac_metadata(q)
    filter_by_tracking_id( filter_by_alert_timestamp(q) )
  end

  def filter_by_tracking_id(q)
    start, stop = params[:tracking_id_start], params[:tracking_id_end]
    q = q.where('tracking_id >= ?', start) unless start.blank?
    q = q.where('tracking_id <= ?', stop) unless stop.blank?
    q
  end

  def filter_by_alert_timestamp(q)
    start, stop = params[:alert_timestamp_start], params[:alert_timestamp_end]
    q = q.where('alert_timestamp >= ?', start) unless start.blank?
    q = q.where('alert_timestamp <= ?', stop) unless stop.blank?
    q
  end
  
  def bool_check(sym)
    return nil unless params.key?(sym)
    params[sym] == "1"
  end
end
