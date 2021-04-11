class RenameChangeColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :change, :monthly_confirmation_change
  end
end
