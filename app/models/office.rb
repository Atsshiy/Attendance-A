class Office < ApplicationRecord
  validates :office_name, presence: true, length: { maximum: 50 }
  validates :office_number, inclusion: { in: (1..1000)}, uniqueness: true
  
end
