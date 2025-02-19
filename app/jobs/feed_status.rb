class FeedStatus
  include Sidekiq::Worker
  include BatchJobs
  sidekiq_options queue: :worker_slow

  def perform(feed_id = nil, schedule = false)
    if schedule
      build
    else
      update(feed_id)
    end
  end

  def update(feed_id)
    feed = Feed.find(feed_id)
    cache = FeedbinUtils.shared_cache(feed.redirect_key)
    feed.update(current_feed_url: cache[:to])
  end

  def build
    enqueue_all(Feed, self.class)
  end
end
