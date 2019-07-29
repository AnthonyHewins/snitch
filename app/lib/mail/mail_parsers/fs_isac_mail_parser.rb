require_relative 'mail_parser'

class FsIsacMailParser
  include MailParser
  include ActionView::Helpers::SanitizeHelper

  def initialize(email_string=nil)
    @string = email_string
  end

  def parse(str=@string)
    @string = strip_tags(str).gsub(/\s*\r\n\s*/, "\n")
    { # Order matters! This eats the string while parsing to make it one pass.
      title: find_then_eat("Title:\n", "\nTracking ID:\n"),
      tracking_id: find_then_eat(nil, "\nReported Date/Time (UTC):\n"),
      alert_timestamp: find_then_eat(nil, "\nRisk:\n"),
      severity: Integer(find_then_eat(nil, "\nAudience:\n")),
      alert: find_then_eat("\nDescription:\n", "\nAffected Products:\n"),
      affected_products: find_then_eat(nil, "\nCorrective Action:\n"),
      corrective_action: find_then_eat(nil, "\nSource(s):\n"),
      sources: find_then_eat(nil, "\nBUGTRAQ ID:")
    }
  end
end
