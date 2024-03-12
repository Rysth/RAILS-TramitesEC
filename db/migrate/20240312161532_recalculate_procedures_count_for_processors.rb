class RecalculateProceduresCountForProcessors < ActiveRecord::Migration[7.1]
  def up
    Processor.find_each do |processor|
      count = processor.procedures.count
      processor.update_columns(procedures_count: count)
    end
  end
end
