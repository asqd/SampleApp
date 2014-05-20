class User
	attr_accessor :name, :email

	def ininitialize(attributes = {})
		@name = attributes[:name]
		@email = attributes[:email]		
	end

	def formatted_email
		"#{@name} <#{@email}>"		
	end
end