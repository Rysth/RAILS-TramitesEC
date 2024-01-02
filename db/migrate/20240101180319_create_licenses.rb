class CreateLicenses < ActiveRecord::Migration[7.1]
  def change
    create_table :licenses do |t|
      t.string :nombre
      t.boolean :active, default: true
      t.timestamps
    end

    add_reference :licenses, :type, foreign_key: true
  end
end
