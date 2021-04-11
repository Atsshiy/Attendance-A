class AddIccToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :indicater_check, :string
  end
end
