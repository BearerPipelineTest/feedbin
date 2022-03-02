module AccountMigrator
  class Setup
    include Sidekiq::Worker

    PER_PAGE = 100

    def perform(import_id)
      @import = Import.find(import_id)
      @access_token = user.account_access_token
      subscriptions_list.dig("feeds").each do |feed|
        @import.import_item.create!(details: feed)
      end
    end

    def subscriptions_list
      @subscriptions_list ||= begin
        url = URI::HTTPS.build({
          host: ENV["ACCOUNT_HOST"],
          path: "/api/v2/subscriptions/list",
          query: default_params.to_query
        })
        HTTP.get(url).parse
      end
    rescue
       @import.failed! #implement this
    end

    def default_params
      { access_token: @access_token }
    end
  end
end