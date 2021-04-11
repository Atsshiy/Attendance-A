class AddCngToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_superior_id, :integer
    add_column :attendances, :change_status, :string
    add_column :attendances, :change_check, :boolean
    add_column :attendances, :change_approval, :integer
    add_column :attendances, :change_next_day_check, :boolean
  end
end
