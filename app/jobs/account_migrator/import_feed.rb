module AccountMigrator
  class ImportFeed
    include Sidekiq::Worker
    def perform(item_id)
      @item = AccountMigrationItem.find(item_id)
      migration = @item.account_migration
      user = migration.user

      client = ApiClient.new(migration.api_token)

      feeds = FeedFinder.feeds(@item.feed_url, import_mode: true)
      feed = feeds.first
      if feed.present?
        user.subscriptions.create_with(title: @item.title).find_or_create_by(feed: feed)
      else
        failed! "No feed found."
        return
      end

      feed_items = client.feed_items_list(feed_id: @item.feed_id)

      ids = feed_items.map {|feed_item| feed_item.dig("guid").gsub(/\s/, "") }

      user.unread_entries.where(feed: feed).delete_all
      entries = feed.entries.where(migration_id: ids)
      unread = entries.map do |entry|
        UnreadEntry.new_from_owners(user, entry)
      end

      result = UnreadEntry.import(unread, validate: false, on_duplicate_key_ignore: true)
      expected_count = feed_items.count
      actual_count = result.ids.count

      @item.message = build_message(expected_count, actual_count)
      @item.complete!
      migration.with_lock do
        unless migration.account_migration_items.where(status: :pending).exists?
          migration.complete!
        end
      end
    rescue ApiClient::Error => exception
      failed! "API Error: #{exception.message}"
    rescue Feedkit::Error => exception
      failed! "No feed found: #{exception.message}"
    rescue => exception
      failed! "Uknown error"
      raise exception unless Rails.env.production?
    end

    def build_message(expected_count, actual_count)
      expected_count_formatted = ActiveSupport::NumberHelper.number_to_delimited(expected_count)
      actual_count_formatted = ActiveSupport::NumberHelper.number_to_delimited(actual_count)
      "Feed imported. Matched #{actual_count_formatted} of #{expected_count_formatted} unread #{'articles'.pluralize(expected_count_formatted)}."
    end

    def failed!(message)
      @item.message = message
      @item.failed!
    end
  end
end