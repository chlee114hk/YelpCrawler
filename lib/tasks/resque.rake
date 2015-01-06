require 'resque/tasks'
require 'resque/pool/tasks'
require 'resque/scheduler/tasks'
require 'resque-retry'
require 'resque/failure/redis'
require 'yelp_crawler_module'

Dir[File.join(Rails.root, 'app', 'jobs', '*.rb')].each { |file| require file }

config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

namespace :resque do
	# this task will get called before resque:pool:setup
	# and preload the rails environment in the pool manager
	task "resque:setup" => :environment do
		# generic worker setup, e.g. Hoptoad for failed jobs
		Resque.redis = Redis.new(:host => config['host'], :port => config['port'])
	end

	task :setup_schedule => "resque:setup" do
		require 'resque-scheduler'

		# If you want to be able to dynamically change the schedule,
		# uncomment this line.  A dynamic schedule can be updated via the
		# Resque::Scheduler.set_schedule (and remove_schedule) methods.
		# When dynamic is set to true, the scheduler process looks for
		# schedule changes and applies them on the fly.
		# Note: This feature is only available in >=2.0.0.
		# Resque::Scheduler.dynamic = true

		# The schedule doesn't need to be stored in a YAML, it just needs to
		# be a hash.  YAML is usually the easiest.
		# Resque.schedule = YAML.load_file('your_resque_schedule.yml')

		# If your schedule already has +queue+ set for each job, you don't
		# need to require your jobs.  This can be an advantage since it's
		# less code that resque-scheduler needs to know about. But in a small
		# project, it's usually easier to just include you job classes here.
		# So, something like this:
		# require 'jobs'
	end
	
	task :scheduler_setup => :setup_schedule

	task "resque:pool:setup" do
		# close any sockets or files in pool manager
		ActiveRecord::Base.connection.disconnect!
		# and re-open them in the resque worker parent
		Resque::Pool.after_prefork do |job|
			ActiveRecord::Base.establish_connection
			Resque.redis.client.reconnect
		end
		YelpCrawlerModule::YelpCrawler.start_crawl(50.0)
	end
end