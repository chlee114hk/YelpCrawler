require 'geometry'
module YelpCrawlerModule
	class YelpCrawler
		US_CONG_DIST_DATA = Rails.root.join('data','cgd112p020.json')

		class << self
			include Geometry

			def get_content(url)
				Rails.logger.info "Fetching data from page #{url}".yellow
				cookie_file = File.join(Rails.root, "config", "cookie.dat")
				cookies = WebAgent::CookieManager.new cookie_file

				clnt = HTTPClient.new()
				clnt.cookie_manager = cookies
				clnt.debug_dev = STDOUT if $DEBUG

				begin
					clnt.get_content(url)
				rescue
					Rails.logger.error $!
				end
			end

			def start_crawl(interval=1.0)
				data = File.read(US_CONG_DIST_DATA)
				Rails.logger.info "US CONG DIST data read successfully".green
				hash = JSON.parse(data)
				geo_data = hash['features'].each do |area|
					area['geometry']['coordinates'].each do |boundary|
						AreaCrawler.perform_async(boundary, interval.to_f)
					end
				end
			end

			def crawl_inside_boundary(boundary, interval=1.0)
				boundary = convex_hull(boundary)
				start = polygon_centroid(boundary)
				unvisited = Queue.new
				unvisited << start
				visited_area = []
				count = 0
				while !unvisited.empty? && count < 100000 do
					count += 1

					point = unvisited.deq

					up = destination_point(point[0], point[1], 0.0, interval)
					left = destination_point(point[0], point[1], 90.0, interval)
					down = destination_point(point[0], point[1], 180.0, interval)
					right = destination_point(point[0], point[1], -90.0, interval)

					BusinessLinkFinder.perform_async(point[0], point[1], right[0], up[1])
puts point
					if (!inside_boundary(up[0], up[1], visited_area) &&
							inside_boundary(up[0], up[1], boundary))
						unvisited.enq(up)
					end

					if (!inside_boundary(left[0], left[1], visited_area) &&
							inside_boundary(left[0], left[1], boundary))
						unvisited.enq(left)
					end

					if (!inside_boundary(down[0], down[1], visited_area) &&
							inside_boundary(down[0], down[1], boundary))
						unvisited.enq(down)
					end

					if (!inside_boundary(right[0], right[1], visited_area) &&
							inside_boundary(right[0], right[1], boundary))
						unvisited.enq(right)
					end

					visited_area << point << [point[0], up[1]] << [right[0],up[1]] << [right[0], point[1]]
					visited_area = convex_hull(visited_area)
				end
			end

		end
	end
end
