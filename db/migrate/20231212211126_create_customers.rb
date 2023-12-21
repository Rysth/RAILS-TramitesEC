class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :cedula, null: false
      t.string :nombres, null: false
      t.string :apellidos, null: false
      t.string :celular, null: false
      t.string :direccion, null: false
      t.string :email, null: false
      t.boolean :active, default: true

      t.timestamps
    end

  end
end
