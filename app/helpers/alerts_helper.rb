module AlertsHelper
  def resolve_cyber_adapt(record)
    resolved = record.resolved
    link_to(
      resolve_icon(resolved),
      set_resolved_cyber_adapt_alert_path(record, resolved: !resolved)
    )
  end

  def resolve_fs_isac(record)
    resolved = record.resolved
    link_to(
      resolve_icon(resolved),
      set_resolved_fs_isac_alert_path(record, resolved: !resolved)
    )
  end

  private
  def resolve_icon(resolved)
    icon_class = "#{resolved ? "green check" : "red times circle"} icon"
    content_tag(:i, nil, class: icon_class)
  end
end
