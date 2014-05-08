RETWEET_CALCULATOR_RECURRING_TIME = 1.minute

# Run background job to calculate most popular retweets
every RETWEET_CALCULATOR_RECURRING_TIME do
  runner "RetweetCalculatorWorker.perform_async"
end
