class AddProcessorReferenceToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_reference :customers, :user, foreign_key: true
    add_reference :customers, :processor, foreign_key: true
  end
end
