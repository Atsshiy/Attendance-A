class AddMalToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthly_apply, :datetime
  end
end
