require_relative './application_record'

class Whitelist < ApplicationRecord
  CsvColumns = [
    :id,
    :regex_string,
    proc {|record| record.paper_trail&.insertion_date}
  ]

  belongs_to :paper_trail, optional: true

  after_save do |record|
    regex = record.regex
    matched = UriEntry.pluck(:id, :uri).select {|_, uri| regex.match? uri}
    UriEntry.destroy matched.map(&:first)
  end
  
  def regex
    @regex_obj ||= Regexp.new self.regex_string
  end

  def regex_string=(new_string)
    @regex_obj = Regexp.new new_string
    super new_string
  end

  def to_a(*cols)
    cols.empty? ? super(*CsvColumns) : super(*cols)
  end
end
