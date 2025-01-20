class CreateAgencies < ActiveRecord::Migration[7.1]
  def change
    create_table :agencies do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.boolean :has_licenses, default: false
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :agencies, :code, unique: true
    add_index :agencies, :name, unique: true
  end
end