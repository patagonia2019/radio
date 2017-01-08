class CreateDistricts < ActiveRecord::Migration[5.0]
  def change
    create_table :districts do |t|
      t.string :name
      t.integer :country_id

      t.timestamps
    end
  end
end
