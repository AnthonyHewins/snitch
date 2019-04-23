module Concerns::RegexValidatable
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  included do
    validate :validate_regex
  end
  
  protected
  def validate_regex
    begin
      Regexp.new regex_string
    rescue RegexpError => e
      errors.add :regex_string, "Invalid regex: #{e.message}"
    end
  end
end
