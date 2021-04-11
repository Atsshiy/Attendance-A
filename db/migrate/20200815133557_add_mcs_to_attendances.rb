class AddMcsToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthly_confirmation_status, :string
  end
end
