module ApplicationHelper
  def abuse_ip(ip)
    ip = ip.to_s
    link_to(ip, "https://www.abuseipdb.com/check/#{ip}")
  end
end
