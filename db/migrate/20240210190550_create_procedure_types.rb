class CreateProcedureTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :procedure_types do |t|
      t.string :name, null: false
      t.boolean :active, default: true
      t.boolean :has_licenses, default: false

      t.timestamps
    end
    add_index :procedure_types, :name, unique: true
  end
end
