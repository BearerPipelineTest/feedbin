require "test_helper"
module AccountMigrator
  class ImportFeedTest < ActiveSupport::TestCase
    setup do
      @user = users(:new)
      @token = "token"
      @migration = @user.account_migrations.create!(api_token: @token)

      @item = @migration.account_migration_items.create!(data: {
        title: "Daring Fireball",
        feed_id: 290,
        feed_url: "http://daringfireball.net/index.xml"
      })
    end

    test "should import feed" do
      stub_request_file("atom.xml", @item.feed_url)
      stub_request_file("migration_ids_response.json", /#{ENV['ACCOUNT_HOST']}\/api\/v2\/feed_items\/list.*?offset=0/,
        headers: {
          "Content-Type" => "application/json; charset=utf-8"
        }
      )
      stub_request_file("migration_empty_response.json", /#{ENV['ACCOUNT_HOST']}\/api\/v2\/feed_items\/list.*?offset=100/,
        headers: {
          "Content-Type" => "application/json; charset=utf-8"
        }
      )
      assert_difference("@user.unread_entries.count", +5) do
        assert_difference("Feed.count", +1) do
          AccountMigrator::ImportFeed.new.perform(@item.id)
        end
      end


      assert @migration.reload.complete?, "Migration should be complete"
      assert @item.reload.complete?, "Migration item should be complete"
      assert_equal "Feed imported. Matched 5 of 5 unread articles.", @item.reload.message
    end

    test "API error should mark as failed" do
      stub_request_file("atom.xml", @item.feed_url)
      stub_request_file("migration_error_response.json", /#{ENV['ACCOUNT_HOST']}\/api\/v2\/feed_items\/list/,
        headers: {
          "Content-Type" => "application/json; charset=utf-8"
        }
      )
      AccountMigrator::ImportFeed.new.perform(@item.id)
      assert @item.reload.failed?, "Item should be marked as failed"
      assert_equal("API Error: Not authorized", @item.message)
    end

  end
end