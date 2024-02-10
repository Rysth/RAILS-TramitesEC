class CreateLicenses < ActiveRecord::Migration[7.1]
  def change
    create_table :licenses do |t|
      t.string :name, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference :license_types, :license_type, foreign_key: true
  end
end
