require 'yelp_crawler_module'
require "errors"

class BusinessInfoCrawler
	include Sidekiq::Worker
	sidekiq_options :queue => :business_info_crawler, :backtrace => true

	def perform(link_id)
		link = Link.find_by_id(link_id)
		link.populate_business
	rescue YelpCrawlerModule::MissingExpectedContent => e
		Rails.logger.error e.message.red
	rescue YelpCrawlerModule::BlockedByRecaptcha => e
		Rails.logger.error e.message.red
		# raise again for retry
		raise YelpCrawlerModule::BlockedByRecaptcha
	end
end