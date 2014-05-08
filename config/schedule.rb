TWEET_DESTROY_WORKER_RECUR_TIME = 1.day

# Run background job to remove old tweets
every TWEET_DESTROY_WORKER_RECUR_TIME do
  runner "TweetDestroyWorker.perform_async"
end
