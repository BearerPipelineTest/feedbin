class AddMigrationIdToEntries < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :entries, :migration_id, :text
    add_index :entries, [:feed_id, :migration_id], where: "migration_id IS NOT NULL", algorithm: :concurrently
  end
end
