class AddApplicationToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :application, :string
  end
end
