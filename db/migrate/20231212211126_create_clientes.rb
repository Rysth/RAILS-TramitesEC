class CreateClientes < ActiveRecord::Migration[7.1]
  def change
    create_table :clientes do |t|
      t.string :cedula, null: false
      t.string :nombres, null: false
      t.string :apellidos, null: false
      t.string :celular, null: false
      t.string :direccion, null: false
      t.string :email, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference :clientes, :user, foreign_key: true
  end
end
