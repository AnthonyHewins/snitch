class FsIsacAlert < ApplicationRecord
  CsvColumns = FsIsacAlert.column_names

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
  validates_numericality_of :severity,
                            only_integer: true,
                            greater_than_equal_to: SEVERITY_MIN,
                            less_than_equal_to: SEVERITY_MAX

  before_save do |record|
    %i(title alert affected_products corrective_action sources).each do |sym|
      record.send(sym).squish!.gsub!(",", '')
    end
    record.comment ||= "Auto-classified as DOES NOT APPLY." unless record.applies
  end

  scope :search, lambda {|q|
    FsIsacAlert.where <<-SQL, q: "%#{q}%"
      title like :q
      or alert like :q
      or affected_products like :q
      or corrective_action like :q
      or sources like :q
      or TEXT(tracking_id) like :q
      or TEXT(alert_timestamp) like :q
    SQL
  }
end
