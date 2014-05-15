module ApplicationHelper

	def full_title(page_titile)
		base_title = "RoR Tutorial App"
		if page_titile.empty?
			base_title
		else
			page_titile
		end
	end
end
