class CreateProcedures < ActiveRecord::Migration[7.1]
  def change
    create_table :procedures do |t|
      t.string :codigo
      t.date :fecha
      t.string :placa
      t.float :valor
      t.float :valor_pendiente
      t.float :ganancia
      t.float :ganancia_pendiente
      t.string :observaciones
      t.timestamps
    end
    
    add_reference :procedures, :user, foreign_key: true
    add_reference :procedures, :processor, foreign_key: true
    add_reference :procedures, :customer, foreign_key: true
    add_reference :procedures, :license, foreign_key: true
    add_reference :procedures, :status, foreign_key: true
  end
end
