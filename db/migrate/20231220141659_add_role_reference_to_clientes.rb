class AddRoleReferenceToClientes < ActiveRecord::Migration[7.1]
  def change
    add_reference :clientes, :role, foreign_key: true
  end
end
