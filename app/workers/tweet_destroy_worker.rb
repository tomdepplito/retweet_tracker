# This is a recurring background job to remove old tweets from
# MongoDB.

class TweetDestroyWorker
  include Sidekiq::Worker

  def perform
    Tweet.destroy_outdated_tweets!
  end
end
