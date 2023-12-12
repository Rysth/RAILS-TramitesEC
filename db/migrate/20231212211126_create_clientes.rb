class CreateClientes < ActiveRecord::Migration[7.1]
  def change
    create_table :clientes do |t|
      t.string :cedula
      t.string :nombres
      t.string :apellidos
      t.string :direccion
      t.string :email
      t.boolean :active

      t.timestamps
    end

    add_reference :clientes, :user, foreign_key: true
  end
end
