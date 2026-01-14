class AddArchivedToProcedureTypes < ActiveRecord::Migration[7.1]
  def change
    add_column :procedure_types, :archived, :boolean, default: false, null: false
  end
end
