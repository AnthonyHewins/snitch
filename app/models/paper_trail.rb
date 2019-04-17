require_relative 'application_record'

class PaperTrail < ApplicationRecord
  CsvColumns = %i(id filename insertion_date created_at updated_at)  
  has_many :uri_entries, dependent: :destroy
  has_many :machines, dependent: :destroy
  has_many :whitelists, dependent: :destroy
  has_many :dhcp_leases, dependent: :destroy

  validates_presence_of :insertion_date
end
