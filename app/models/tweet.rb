# This class encapsulates all information pertaining to a tweet.

class Tweet
  include Mongoid::Document

  field :text, type: String
  field :twitter_id, type: String
  field :read_time, type: Time
  field :retweet_count, type: Integer

  validates_presence_of :twitter_id, :text, :read_time
  validates_numericality_of :retweet_count

  DEFAULT_TIME_WINDOW = 1.minute

  # This method will query MongoDB for the most retweeted tweets
  # within a given time window.  The starting_time argument should be
  # an instance of Time that represents how far into the past the query
  # should search.  The top_count argument indicates how many records
  # (in descending order) should be returned.
  def self.calculate_most_retweeted(starting_time, top_count)
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

                    /*
                      Sort the retweet counts in descending order,
                      then find the delta between min and max to
                      calculate the number of retweets in
                      the given time period per twitter_id.
                    */
                    sortedValues = values.sort(function(valA, valB) {
                      return valB.retweetCount > valA.retweetCount;
                    });

                    min = sortedValues[values.length - 1].retweetCount;
                    max = sortedValues[0].retweetCount

                    reducedObject.retweetCount = max - min;
                    return reducedObject;
                  };
                }

    # Select tweets within the time window then run the map reduce query.
    Tweet.where(:read_time.gte => starting_time,
                :read_time.lt => starting_time + DEFAULT_TIME_WINDOW).
      map_reduce(map, reduce).out(inline: true).
      sort do |a, b|
        b['value']['retweetCount'] <=> a['value']['retweetCount']
      end[0..top_count-1]
  end
end
