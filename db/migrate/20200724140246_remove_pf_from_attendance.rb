class RemovePfFromAttendance < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :plan_finished_at, :datetime
  end
end
