require 'active_support/concern'

module MachineHook
  extend ActiveSupport::Concern

  included do
    belongs_to :paper_trail, required: false
    belongs_to :department, required: false

    validates_uniqueness_of :host, allow_nil: false, case_sensitive: false

    before_save do |record|
      u = record.user
      record.user = u.blank? ? nil : u.strip.downcase

      record.host = record.host.downcase.gsub('flexibleplan\\', '')
    end
  end
end
