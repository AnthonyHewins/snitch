require_relative './application_record'
require_relative './machine'
require_relative './uri_entry'
require_relative './whitelist'

# Require every log parser so when it's constantized ruby recognizes it
Dir.glob(
  File.expand_path(
    File.join __FILE__, '../log_parsers/*'
  )
).each {|f| require_relative f}

class PaperTrail < ApplicationRecord
  has_many :uri_entries, dependent: :nullify
  has_many :machines, dependent: :nullify
  has_many :whitelists, dependent: :nullify

  validates_presence_of :insertion_date

  before_save do |record|
    type = record.log_type

    case type
    when NilClass
    when Class
      check_valid_type type
    when String
      check_valid_type type.constantize
    else
      raise TypeError, ":log_type must be something that can constantize to a class"
    end
  end

  def model
    @model ||= self.log_type.constantize
  end

  private
  def check_valid_type(model_type)
    unless DataLog.descendants.include? model_type
      raise ActiveRecord::RecordNotSaved, "must be a descendant of DataLog, got #{model_type}"
    end
  end
end
