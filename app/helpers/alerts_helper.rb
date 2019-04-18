module AlertsHelper
  def resolve_cyber_adapt(record)
    resolved = record.resolved
    resolve_icon resolved, set_booleans_cyber_adapt_alert_path(record, resolved: !resolved)
  end

  def resolve_fs_isac(record)
    resolved = record.resolved
    resolve_icon resolved, set_booleans_fs_isac_alert_path(record, resolved: !resolved)
  end

  def mark_as_applies(record)
    applies = record.applies
    link_to(applies ? "Yes" : "No", set_booleans_fs_isac_alert_path(record, applies: !applies))
  end

  private
  def resolve_icon(resolved, path)
    icon_class = "#{resolved ? "green check" : "red times circle"} icon"
    link_to content_tag(:i, nil, class: icon_class), path
  end
end
