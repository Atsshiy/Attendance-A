class RemoveaffiliationtoAttendance < ActiveRecord::Migration[5.1]
  def change
    remove_column :Attendances, :affiliation, :string
  end
end
