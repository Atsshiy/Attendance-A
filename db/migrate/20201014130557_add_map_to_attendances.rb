class AddMapToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthly_approval, :integer
  end
end
