class AddCourseIdToProcedures < ActiveRecord::Migration[7.1]
  def change
    add_reference :procedures, :course, null: true, foreign_key: true
  end
end
