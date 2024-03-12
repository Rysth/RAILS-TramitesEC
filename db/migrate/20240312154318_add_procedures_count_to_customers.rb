class AddProceduresCountToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :procedures_count, :integer, default: 0
  end
end
