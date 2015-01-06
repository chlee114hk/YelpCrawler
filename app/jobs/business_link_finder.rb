require 'yelp_crawler_module'
require "errors"

class BusinessLinkFinder
	include Sidekiq::Worker
	sidekiq_options :queue => :business_link_finder, :backtrace => true

	def perform(long1, lat1, long2, lat2)
		Link.grep_links(long1, lat1, long2, lat2)
	rescue YelpCrawlerModule::MissingExpectedContent => e
		Rails.logger.error e.message.red
	rescue YelpCrawlerModule::BlockedByRecaptcha => e
		Rails.logger.error e.message.red
		# raise again for retry
		raise YelpCrawlerModule::BlockedByRecaptcha
	end
end