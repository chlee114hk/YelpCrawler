require "resque/errors"
require "errors"

class BusinessLinkFinder
	include Resque::Plugins::UniqueJob
	extend Resque::Plugins::Retry

	@queue = :business_link_finder
	@retry_delay = 120
	#@sleep_after_requeue = 60
	@retry_delay_multiplicand_min = 1.0
	@retry_delay_multiplicand_max = 2.0

	class << self
		def perform(long1, lat1, long2, lat2)
			Link.grep_links(long1, lat1, long2, lat2)
		rescue Resque::TermException
			Rails.logger.error "BusinessLinkFinder job cleaned up!"
		rescue YelpCrawlerModule::BlockedByRecaptcha, YelpCrawlerModule::MissingExpectedContent => e
			Rails.logger.error e.message.red
		end
	end
end