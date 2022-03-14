class ApiClient
  class Error < StandardError
  end

  def initialize(access_token)
    @access_token = access_token
  end

  def feed_items_list(feed_id:)
    offsets = [0, 100, 200, 300, 400]
    feed_items = []

    offsets.each do |offset|
      response = request(
        path: "/api/v2/feed_items/list",
        params: {
          read:    false,
          feed_id: feed_id,
          offset:  offset
        }
      )
      items = response.dig("feed_items")
      break if items.count == 0
      feed_items += items
    end
    feed_items
  end

  def subscriptions_list
    request(path: "/api/v2/subscriptions/list")
  end

  private

  def request(path:, params: {})
    url = URI::HTTPS.build({
      host: ENV["ACCOUNT_HOST"],
      path: path,
      query: default_params.merge(params).to_query
    })
    response = HTTP.follow().headers(user_agent: "Feedbin").get(url)

    raise ApiClient::Error.new(response.status.reason) unless response.status.success?

    result = response.parse
    error_message = result.dig("error")
    status = result.dig("result")

    if !error_message.nil? || status == "error"
      raise ApiClient::Error.new(error_message || "Unknown API error.")
    end

    result
  end

  def default_params
    { access_token: @access_token }
  end
end