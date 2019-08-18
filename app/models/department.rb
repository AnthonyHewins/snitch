require 'application_record'

class Department < ApplicationRecord
  has_many :machines, dependent: :restrict_with_exception
end
