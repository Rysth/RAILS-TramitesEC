class CreateProcedures < ActiveRecord::Migration[7.1]
  def change
    create_table :procedures do |t|
      t.string :code, null: false
      t.date :date, null: false
      t.string :plate
      t.float :cost, null: false
      t.float :cost_pending, null: false
      t.float :profit, null: false
      t.float :profit_pending, null: false
      t.text :comments
      t.boolean :is_paid, default: false, null: false
      t.boolean :active, default: true, null: false
      t.references :user, null: false, foreign_key: true
      t.references :processor, foreign_key: true
      t.references :customer,  foreign_key: true
      t.references :procedure_type, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true
      t.references :license, foreign_key: true

      t.timestamps
    end
  end
end
