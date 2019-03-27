require_relative 'application_record'

class PaperTrail < ApplicationRecord
  CsvColumns = %i(id filename insertion_date created_at updated_at)  
  has_many :uri_entries, dependent: :nullify
  has_many :machines, dependent: :nullify
  has_many :whitelists, dependent: :nullify

  validates_presence_of :insertion_date

  def to_a(*cols)
    cols.empty? ? super(*CsvColumns) : super(*cols)
  end
end
