module Geometry
	R = 6371

	def destination_point(longitude, latitude, bearing, distance)
		rad_bearing = bearing / 180.0 * Math::PI
		longitude = longitude / 180.0 * Math::PI
		latitude = latitude / 180.0 * Math::PI
		d = distance / R

		lat =  Math.asin( Math.sin(latitude) * Math.cos(d) +
											Math.cos(latitude) * Math.sin(d) * Math.cos(rad_bearing) )
		long = longitude +
					 Math.atan2( Math.sin(rad_bearing) * Math.sin(d) * Math.cos(latitude),
											 Math.cos(d) - Math.sin(latitude) * Math.sin(lat) )
		long = (long + 3*Math::PI) % (2*Math::PI) - Math::PI

		long = long / Math::PI * 180.0
		lat = lat / Math::PI * 180.0
		[long, lat]
	end

	def cross(o, a, b)
		(a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
	end

	def convex_hull(points)
		points.sort!.uniq!
		return points if points.length < 3

		lower = Array.new
		points.each{|p|
		while lower.length > 1 and cross(lower[-2], lower[-1], p) <= 0 do lower.pop end
			lower.push(p)
		}
		upper = Array.new
		points.reverse_each{|p|
		while upper.length > 1 and cross(upper[-2], upper[-1], p) <= 0 do upper.pop end
			upper.push(p)
		}
		return lower[0...-1] + upper[0...-1]
	end

	def polygon_centroid(coordinates)
		consecutive_pairs = (coordinates + [coordinates.first]).each_cons(2)
		area = (1.0/2) * consecutive_pairs.map do |(x0, y0), (x1, y1)|
			(x0*y1) - (x1*y0)
		end.inject(:+)

		consecutive_pairs.map do |(x0, y0), (x1, y1)|
			cross = (x0*y1 - x1*y0)
			[(x0+x1) * cross, (y0+y1) * cross]
		end.transpose.map { |cs| cs.inject(:+) / (6*area) }
	end

	def inside_boundary(longitude, latitude, boundary)
		last_point = boundary.last
		is_inside = false

		boundary.each do |point|
			if (longitude - point[0]).abs < 0.001 && (latitude - point[1]).abs < 0.001
				return true
			end

			x1 = last_point[0]
			x2 = point[0]
			dx = x2 - x1

			if dx.abs > 180.0
				if longitude > 0
					while x1 < 0 do
						x1 += 360.0
					end
					while x2 < 0 do
						x2 += 360.0
					end
				else
					while x1 > 0 do
						x1 -= 360.0
					end
					while x2 > 0
						x2 -= 360.0
					end
				end
				dx = x2 -x1
			end

			if (x1 <= longitude && x2 > longitude) || (x1 >= longitude && x2 < longitude)
				grad = (point[1] - last_point[1]) / dx
				intersectAtLat = last_point[1] + ((longitude - x1) * grad)

				if intersectAtLat > latitude
					is_inside = !is_inside
				end
			end
			last_point = point
		end
		is_inside
	end

end