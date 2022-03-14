class AccountMigrationItem < ApplicationRecord
  belongs_to :account_migration

  enum status: [:pending, :complete, :failed]

  def title
    data.dig("title")
  end

  def feed_id
    data.dig("feed_id")
  end

  def feed_url
    data.dig("feed_url")
  end
end
