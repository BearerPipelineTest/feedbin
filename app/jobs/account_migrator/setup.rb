module AccountMigrator
  class Setup
    include Sidekiq::Worker

    def perform(migration_id)
      @migration = AccountMigration.find(migration_id)
      client = ApiClient.new(@migration.api_token)
      subscriptions = client.subscriptions_list
      subscriptions.dig("feeds").each do |feed|
        @migration.account_migration_items.create!(data: feed)
      end
    rescue ApiClient::Error, HTTP::Error => exception
      failed! "API Error: #{exception.message}"
    rescue => exception
      failed! "Unknown error"
      raise exception unless Rails.env.production?
    end

    def failed!(message)
      @migration.message = message
      @migration.failed!
    end
  end
end