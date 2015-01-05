require 'rubygems'
require 'RMagick'

module ColorModule
	include Magick
	def parse_color(color)
		m_color = Magick::Pixel.from_color(color)
		[m_color.red, m_color.green, m_color.blue]
	end

	# Compose two colors with given % of first one
	#   (second color % = 100 - first_color%)
	#   color1, color2:   string representation of color in RGB "#beef00"
	#   proportion:      Fixnum from 0 to 100
	def compose_colors(color1, color2, proportion)
		c1, c2 = parse_color(color1), parse_color(color2)
		color = (0..2).inject([]) do |res, i|
			res[i] = (c1[i] / 100 * proportion) + (c2[i]/100 * (100 - proportion))
			res
		end
		Magick::Pixel.new(*color).to_color(Magick::AllCompliance, false, 8, true)
	end

	def hsla(color_string)
		Magick::Pixel.from_color(color_string).to_hsla
	end

	# Change HSLA parameters (hue, saturation, lightness, alpha) of color
	#   and return its RGB string representation ("#beef00")
	# Note: the result disregards alpha value since it is not representable
	#   in CSS yet
	#   color_string:   string representation of color in RGB "#beef00"
	#   Options range:  H:    (float) 0.0 - 360.0
	#                   S, L: (float) 0.0 - 255.0
	#                   A:    (float) 0.0 - 1.0
	def change_hsla(color_string, options = {})
		hsla = hsla(color_string)
		Magick::Pixel.from_hsla(
			options[:h] || hsla[0],
			options[:s] || hsla[1],
			options[:l] || hsla[2],
			hsla[3]).
				to_color(Magick::AllCompliance, false, 8, true)
	end
end