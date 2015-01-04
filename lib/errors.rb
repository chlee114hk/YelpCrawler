module YelpCrawlerModule
	# Raised when redirected by Yelp to a robot detecting page 
	class BlockedByRecaptcha < StandardError; end
	
	# Raised when fetched a page without expected content
	class MissingExpectedContent < StandardError; end
end