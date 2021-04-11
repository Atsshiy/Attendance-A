class ChangeDatatypechangeStatusOfAttendances < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :change_status, :integer
  end
end
