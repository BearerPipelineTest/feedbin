class CreateAccountMigrations < ActiveRecord::Migration[7.0]
  def change
    create_table :account_migrations do |t|
      t.references :user, foreign_key: false, null: false
      t.text :api_token, null: false
      t.bigint :status, null: false, default: 0
      t.jsonb :data, null: false, default: {}
      t.text :message

      t.timestamps
    end
    add_index :account_migrations, :api_token, unique: true
  end
end
