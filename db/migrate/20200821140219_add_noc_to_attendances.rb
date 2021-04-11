class AddNocToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :notice_overtime_change, :boolean
  end
end
