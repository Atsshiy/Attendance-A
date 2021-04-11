class AddSprToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :superior_id, :integer
    add_column :attendances, :superior_name, :string
  end
end
