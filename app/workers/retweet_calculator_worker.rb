# This is a recurring background job to calculate the most retweeted
# tweets and cache the information in Redis to be accessed in the view.

class RetweetCalculatorWorker
  include Sidekiq::Worker

  TOP_RETWEET_NUM = 10

  def perform
    start_time = Time.now.beginning_of_minute
    most_retweeted = Tweet.calculate_most_retweeted(start_time, TOP_RETWEET_NUM)
    # Only cache pertinent tweet data
    most_retweeted.map! { |tweet_info| tweet_info['value'] }
    $redis.set(start_time.min, most_retweeted)
  end
end
