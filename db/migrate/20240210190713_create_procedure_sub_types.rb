class CreateProcedureSubTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :procedure_sub_types do |t|
      t.string :name, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference :procedure_sub_types, :procedure_type, foreign_key: true
  end
end
