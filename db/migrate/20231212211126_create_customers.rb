class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :identification, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone, null: false
      t.string :email, null: false
      t.string :address, default: ''
      t.boolean :is_direct, default: false
      t.boolean :active, default: true

      t.timestamps
    end

  end
end
