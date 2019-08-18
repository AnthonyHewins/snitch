require 'concerns/regex_validatable'

class FsIsacIgnore < ApplicationRecord
  include Concerns::RegexValidatable

  def self.all_regexps
    string_ref_to_cut_down_overhead = 'i'
    pluck(:regex_string, :case_sensitive).map do |str, i|
      Regexp.new(str, i ? nil : string_ref_to_cut_down_overhead)
    end
  end

  def regex
    @regex_obj ||= Regexp.new(regex_string, case_sensitive ? nil : 'i')
  end

  def regex_string=(new_string)
    @regex_obj = Regexp.new(new_string, case_sensitive ? nil : 'i')
    super new_string
  end

  def case_sensitive=(new_boolean)
    @regex_obj = Regexp.new(regex_string, new_boolean ? nil : 'i')
    super new_boolean
  end
end
