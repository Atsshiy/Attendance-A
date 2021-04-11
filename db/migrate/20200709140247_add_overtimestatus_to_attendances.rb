class AddOvertimestatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_status, :string
    add_column :attendances, :instructor_confirmation, :string
  end
end
