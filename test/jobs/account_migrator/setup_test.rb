require "test_helper"
module AccountMigrator
  class SetupTest < ActiveSupport::TestCase
    setup do
      @user = users(:new)
      @token = "token"
      @migration = @user.account_migrations.create!(api_token: @token)
      @request_url = "https://#{ENV['ACCOUNT_HOST']}/api/v2/subscriptions/list?access_token=#{@token}"
    end

    test "should build account migration job" do
      stub_request_file("migration_subscriptions_response.json", @request_url,
        headers: {
          "Content-Type" => "application/json; charset=utf-8"
        }
      )

      assert_difference("AccountMigrationItem.count", +1) do
        AccountMigrator::Setup.new.perform(@migration.id)
      end

      assert_equal("Daring Fireball", @migration.account_migration_items.first.title)
      assert_equal(290, @migration.account_migration_items.first.feed_id)
      assert_equal("http://daringfireball.net/index.xml", @migration.account_migration_items.first.feed_url)
    end

    test "Network error should mark as failed" do
      stub_request(:get, @request_url).to_return(status: 500)
      AccountMigrator::Setup.new.perform(@migration.id)
      assert @migration.reload.failed?, "AccountMigration should be marked as failed"
      assert_equal("API Error: Internal Server Error", @migration.message)
    end

    test "API error should mark as failed" do
      stub_request_file("migration_error_response.json", @request_url,
        headers: {
          "Content-Type" => "application/json; charset=utf-8"
        }
      )
      AccountMigrator::Setup.new.perform(@migration.id)
      assert @migration.reload.failed?, "AccountMigration should be marked as failed"
      assert_equal("API Error: Not authorized", @migration.message)
    end

  end
end
