class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.date :date, null: false
      t.float :value, null: false
      t.string :receipt_number
      t.references :payment_type, null: false, foreign_key: true
      t.references :procedure, null: false, foreign_key: true

      t.timestamps
    end
  end
end
