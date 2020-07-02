class Office < ApplicationRecord
  validates :office_name, presence: true, length: { maximum: 50 }
  validates :office_number, inclusion: { in: (1..999)}, uniqueness: true
  
end
