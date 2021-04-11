class AddOtsToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_approval, :integer
    add_column :attendances, :overtime_check, :string
  end
end
