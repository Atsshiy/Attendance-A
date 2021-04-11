class ChangeDatatypemonthlyConfirmationStatusOfAttendances < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :monthly_confirmation_status, :integer
  end
end
