class Category < ActiveRecord::Base
 	has_and_belongs_to_many :business

  attr_accessible :name
	
	def color
		Category.color_table[id - 1]
	end
	
	class << self
		include ColorModule

		def color_table
			generate_color_table unless @table
			@table
		end
	
		def generate_color_table
			colors = []
			colors[0] = "#FF0000"
			for i in 1..Category.all.size-1
				c = hsla(colors[i-1])
			  colors[i] = change_hsla(
					colors[i-1],
					{
						:h => (c[0] + 10 > 360) ?
						  (c[0] + 10 - 360) :
							(c[0] + 10),
						:s => c[1],
						:l => (i / 36) % 2 == 0 ?
						  (
							  (c[2] + 16 * (i / 36) > 255) ?
							  (c[2] + 16 * (i / 36) - 255) :
							  (c[2] + 16 * (i / 36))
							) :
						  (
							  (c[2] - 16 * (i / 36) < 0) ?
							  (c[2] - 16 * (i / 36) + 255) :
							  (c[2] - 16 * (i / 36))
							)
					}
				)
			end
			@table = colors
		end

	end
end
