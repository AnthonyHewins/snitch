require 'application_record'
require 'concerns/regex_validatable' 

class Whitelist < ApplicationRecord
  include Concerns::RegexValidatable

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

  scope :search, lambda {|q|
    Whitelist.left_outer_joins(:paper_trail).where <<-SQL, q: "%#{q}%"
      regex_string like :q or TEXT(paper_trails.insertion_date) like :q
    SQL
  }

  def regex
    @regex_obj ||= Regexp.new self.regex_string
  end

  def regex_string=(new_string)
    @regex_obj = Regexp.new new_string
    super new_string
  end
end
