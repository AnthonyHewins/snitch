require 'active_support/concern'

module FsIsacAlertHook
  extend ActiveSupport::Concern

  included do
    validates :tracking_id,
              uniqueness: true,
              presence: true,
              inclusion: {in: 1..2147483647}

    %i(
     title alert affected_products corrective_action sources alert_timestamp
    ).each do |sym|
      validates_presence_of sym
    end

    SEVERITY_MIN = 1
    SEVERITY_MAX = 10
    validates :severity, inclusion: {in: SEVERITY_MIN..SEVERITY_MAX}

    before_save do |record|
      %i(title alert affected_products corrective_action sources).each do |sym|
        record.send(sym).squish!.gsub!(",", '')
      end
      record.comment ||= "Auto-classified as DOES NOT APPLY." unless record.applies
    end
  end
end
