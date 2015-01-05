require "resque/errors"
require "errors"

class BusinessInfoCrawler
	include Resque::Plugins::UniqueJob
	extend Resque::Plugins::Retry

	@queue = :business_info_crawler
	@retry_delay = 120
	#@sleep_after_requeue = 60
	@retry_delay_multiplicand_min = 1.0
	@retry_delay_multiplicand_max = 2.0

	class << self
		def perform(link_id)
			link = Link.find_by_id(link_id)
			link.populate_business
		rescue Resque::TermException
			Rails.logger.error "BusinessInfoCrawler job cleaned up!"
		rescue YelpCrawlerModule::BlockedByRecaptcha, YelpCrawlerModule::MissingExpectedContent => e
			Rails.logger.error e.message.red
		end
	end
end