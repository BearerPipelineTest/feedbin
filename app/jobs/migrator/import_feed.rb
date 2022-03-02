module AccountMigrator
  class ImportFeed
    include Sidekiq::Worker

    PER_PAGE = 100

    def perform(import_item_id)

    end

    def feed_items_list(offset: 0)
      params = {
        read:   false,
        offset: offset
      }
      url = URI::HTTPS.build({
        host: ENV["ACCOUNT_HOST"],
        path: "/api/v2/feed_items/list",
        query: default_params.merge(params).to_query
      })
      HTTP.get(url).parse
    end

    def default_params
      { access_token: @access_token }
    end
  end
end