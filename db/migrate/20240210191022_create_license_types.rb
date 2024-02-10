class CreateLicenseTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :license_types do |t|
      t.string :name, null: false
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :license_types, :name, unique: true
  end
end
