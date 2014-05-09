source 'https://rubygems.org'
ruby '2.1.1'
gem 'rails', '4.1.0'

#DATA STORES
gem 'mongoid', '~> 4.0.0.beta1', github: 'mongoid/mongoid'
gem 'bson_ext'
gem 'redis'

#WEB SERVERS
gem 'unicorn'
gem 'thin', group: :development

#API
gem 'twitter'
gem 'oauth'

#KEYS
gem 'figaro'

#QUEUES
gem 'sidekiq', '~> 3.0.1'
gem 'sinatra'
gem 'slim'

#JOBS
gem 'whenever', :require => false

#JSON
gem 'multi_json'

#FRONT END
gem 'haml-rails'
gem 'uglifier', '>= 1.3.0'
#gem 'bootstrap-sass'

#JAVASCRIPT
gem 'jquery-rails'
gem 'coffee-rails', '~> 4.0.0'
gem 'jbuilder', '~> 2.0'

group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
end

group :test do
  gem 'webmock', '~> 1.17.4'
  gem 'database_cleaner'
end

group :production do
  gem 'rails_12factor'
end

#STANDARD RAILS STUFF
gem 'sass-rails', '~> 4.0.3'
#gem 'turbolinks'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development

