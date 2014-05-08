# This class enables access to Twitter's streaming API

class TwitterStream

  # Create a new Twitter streaming client if one has not already
  # been created.  It will be necessary to call this method for all
  # interactions with Twitter's API.
  def self.client
    @client ||= Twitter::Streaming::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['OAUTH_TOKEN']
      config.access_token_secret = ENV['OAUTH_SECRET']
    end
  end

  # Listen to a random sampling of tweets and store the tweet
  # in MongoDB if it is an original tweet that has been
  # retweeted by other users.  This method is intended to run
  # indefinitely.
  def self.listen_for_retweets
    client.sample do |object|
      case object
      when Twitter::Tweet
        if object.retweet_count > 0
          tweet = Tweet.new(retweet_count: object.retweet_count,
                            text: object.text,
                            twitter_id: object.id,
                            read_time: Time.now)
          tweet.save
        end
      end
    end
  end
end
