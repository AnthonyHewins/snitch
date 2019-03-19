require_relative './application_record'

class Whitelist < ApplicationRecord
  belongs_to :paper_trail

  def regex
    @regex_obj ||= Regexp.new self.regex_string
  end

  def regex_string=(new_string)
    @regex_obj = Regexp.new new_string
    super new_string
  end

  def to_csv_row
    [self.id, self.regex_string]
  end
end
