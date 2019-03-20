require_relative './application_record'

class Whitelist < ApplicationRecord
  belongs_to :paper_trail, optional: true

  def regex
    @regex_obj ||= Regexp.new self.regex_string
  end

  def regex_string=(new_string)
    @regex_obj = Regexp.new new_string
    super new_string
  end
end
