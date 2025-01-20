class AddAgencyToProcedures < ActiveRecord::Migration[7.1]
  def change
    add_reference :procedures, :agency, null: true, foreign_key: true
  end
end
