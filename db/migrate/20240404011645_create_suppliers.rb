class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :identification, null: false
      t.string :name, null: false
      t.string :phone, null: false
      t.string :email
      t.boolean :active, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
