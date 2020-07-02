class CreateOffices < ActiveRecord::Migration[5.1]
  def change
    create_table :offices do |t|
      t.integer :office_number
      t.string :office_name
      t.string :office_category

      t.timestamps
    end
  end
end
