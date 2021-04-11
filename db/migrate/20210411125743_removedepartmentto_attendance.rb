class RemovedepartmenttoAttendance < ActiveRecord::Migration[5.1]
  def change
    remove_column :Users, :department, :string
  end
end
