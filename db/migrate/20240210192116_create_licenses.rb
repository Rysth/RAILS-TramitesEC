class CreateLicenses < ActiveRecord::Migration[7.1]
  def change
    create_table :licenses do |t|
      t.string :name, null: false
      t.boolean :active, default: true
      t.references :license_type, foreign_key: true

      t.timestamps
    end
  end
end
