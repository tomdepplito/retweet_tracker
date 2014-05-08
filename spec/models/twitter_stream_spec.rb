require 'spec_helper'

describe TwitterStream do
  describe 'listen_for_retweets' do
    let(:tweet_object) { double('Tweet',
                                retweet_count: 2,
                                text: 'some text',
                                twitter_id: 'some ID',
                                read_time: Time.now)
                       }
    let(:tweet) { Twitter::Tweet }
    let(:api_objects) { tweet }

    it 'should process API objects' do
      Twitter::Tweet.any_instance.stub(:===).and_return(true)
      tweet.stub(:class).and_return(Twitter::Tweet)
      TwitterStream.client.should_receive(:sample).and_yield(api_objects)
      TwitterStream.listen_for_retweets
    end
  end
end
