class Tweet
  include Mongoid::Document

  field :text, type: String
  field :twitter_id, type: String
  field :read_time, type: Time
  field :retweet_count, type: Integer

  validates_presence_of :twitter_id, :text, :read_time
  validates_numericality_of :retweet_count

  def self.most_retweeted(time_window, top_count)
    map     = %Q{
                  var key = this.twitter_id;
                  var value = {
                                 twitterID: key,
                                 retweetCount: this.retweet_count,
                                 text: this.text
                               };
                  emit(key, value);
                }

    reduce  = %Q{ function(key, values) {
                    var reducedObject = {
                                          twitterID: key,
                                          text: values[0].text,
                                          retweetCount: 0
                                         };

                    var min = max = values[0].retweetCount;

                    values.forEach(function(value) {
                      var currentCount = value.retweetCount;

                      if(currentCount > max) {
                        max = currentCount;
                      }

                      if(currentCount < min) {
                        min = currentCount;
                      }
                    });

                    reducedObject.retweetCount = max - min;
                    return reducedObject;
                  };
                }

    Tweet.gte(read_time: Time.now - time_window).
      map_reduce(map, reduce).out(inline: true).
      sort_by do |a,b|
        b.try([:value]).try([:retweetCount]) <=> a.try([:value]).try([:retweetCount])
      end[0..top_count-1]
  end
end
