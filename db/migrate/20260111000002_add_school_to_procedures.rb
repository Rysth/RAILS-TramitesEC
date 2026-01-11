class AddSchoolToProcedures < ActiveRecord::Migration[7.1]
  def change
    add_reference :procedures, :school, null: true, foreign_key: true
  end
end
