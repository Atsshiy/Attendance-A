class AddCalToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :calendar, :date
  end
end
