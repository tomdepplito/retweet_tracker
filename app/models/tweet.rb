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
                                 retweetCount: this.retweet_count,
                                 text: this.text
                               };
                  emit(key, value);
                }

    reduce  = %Q{ function(key, values) {
                    var min, max, sortedValues;
                    var reducedObject = {text: values[0].text};

                    sortedValues = values.sort(function(valA, valB) {
                      return valB.retweetCount > valA.retweetCount;
                    });

                    min = sortedValues[values.length - 1].retweetCount;
                    max = sortedValues[0].retweetCount

                    reducedObject.retweetCount = max - min;
                    return reducedObject;
                  };
                }

    Tweet.gte(read_time: Time.now - time_window).
      map_reduce(map, reduce).out(inline: true).
      sort do |a, b|
        b['value']['retweetCount'] <=> a['value']['retweetCount']
      end[0..top_count-1]
  end
end
