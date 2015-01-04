# [app_dir]/config/resque_web_config.rb
require 'resque-retry'
require 'resque-retry/server'

# Make sure to require your workers & application code below this line:
Dir[File.join(Rails.root, 'app', 'jobs', '*.rb')].each { |file| require file }