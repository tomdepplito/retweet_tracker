require 'spec_helper'

describe Tweet do
  describe '.calculate_most_retweeted' do
    let(:retweet_counts) { Tweet.calculate_most_retweeted(5.minutes) }

    before :all do
      @retweet_1_id = 'retweet_1_id'
      @retweet_1_min = 2
      @retweet_1_max = 10
      tweet_info = {text: 'some text',
                    read_time: Time.now - rand(1..4).minutes,
                    twitter_id: 'retweet_2_id',
                    retweet_count: 0}
      tweets = [tweet_info, tweet_info.merge(retweet_count: 2),
                tweet_info.merge(retweet_count: @retweet_1_min, twitter_id: @retweet_1_id),
                tweet_info.merge(retweet_count: @retweet_1_max, twitter_id: @retweet_1_id)]
      populate_db(tweets)
    end

    it 'returns only unique twitter_ids' do
      ids = retweet_counts.map { |tweet_info| tweet_info['_id'] }
      ids.count.should == ids.uniq.count
    end

    it 'returns retweet counts in descending order' do
      retweet_counts.each_with_index do |tweet_info, index|
        unless index == 0
          current_count = retweet_counts[index]['value']['retweetCount']
          last_count = retweet_counts[index - 1]['value']['retweetCount']
          expect(last_count).to be > current_count
        end
      end
    end

    context 'when the number of retweets increases during the time window' do
      it 'returns the number of retweets that occurred' do
        tweet_info = retweet_counts.detect{ |info| info['_id'] == @retweet_1_id }
        num_retweets = tweet_info['value']['retweetCount'].to_i
        num_retweets.should == @retweet_1_max - @retweet_1_min
      end
    end

    context 'when the top_count is greater than the number of persisted tweets' do
      it 'returns counts for every tweet' do
        retweet_counts.count.should == 2
      end
    end

    context 'when the top_count is less than the number of persisted tweets' do
      it 'returns a number of records equal to the top_count' do
        Tweet.calculate_most_retweeted(5.minutes, 1).count.should == 1
      end
    end
  end

  describe '.destroy_outdated_tweets!' do
    before :all do
      @tweet_read_time = Time.now - Tweet::TWEET_PERSISTENCE_WINDOW
      tweet_info = { twitter_id: '1',
                     text: 'some text',
                     read_time: @tweet_read_time,
                     retweet_count: 10
                   }
      populate_db(tweet_info, tweet_info.merge(read_time: Time.now))
    end

    it 'removes tweets that are older than the time persistence window' do
      Tweet.destroy_outdated_tweets!
      Tweet.where(:read_time.lte => @tweet_read_time).count.should == 0
    end

    it 'does not remove tweets that were read within the time persistence window' do
      tweet_count = Tweet.where(:read_time.gt => @tweet_read_time).count
      Tweet.destroy_outdated_tweets!
      Tweet.count.should == tweet_count
    end
  end

  # This method creates instances of the Tweet class in MongoDB for testing
  def populate_db(*args)
    args.each do |tweet_info|
      Tweet.create(tweet_info)
    end
  end
end
