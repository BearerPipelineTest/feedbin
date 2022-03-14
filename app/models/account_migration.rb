class AccountMigration < ApplicationRecord
  belongs_to :user
  has_many :account_migration_items
  enum status: [:pending, :complete, :failed]
end
