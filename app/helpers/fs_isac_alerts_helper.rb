module FsIsacAlertsHelper
  def resolve_icon(record)
    resolved = record.resolved
    icon_class = "#{resolved ? "green check" : "red times circle"} icon"
    link_to(
      content_tag(:i, nil, class: icon_class),
      set_resolved_fs_isac_alert_path(record, resolved: !resolved)
    )
  end
end
