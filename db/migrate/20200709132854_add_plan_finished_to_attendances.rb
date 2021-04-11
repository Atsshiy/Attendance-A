class AddPlanFinishedToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :plan_finished_at, :datetime
  end
end
