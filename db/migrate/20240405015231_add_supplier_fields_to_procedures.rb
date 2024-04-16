class AddSupplierFieldsToProcedures < ActiveRecord::Migration[7.1]
  def change
    add_column :procedures, :supplier_amount, :float, default: 0
    add_reference :procedures, :supplier, null: true, foreign_key: true
  end
end
