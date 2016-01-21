require "sinatra"
require "bcrypt"
require "pg"

module Forum
	class Server <Sinatra::Base
		enable :session

		@@db = PG.connect({dbname: "compact_living_db"})
		
		get "/" do
			@bob = "howdy"
			erb :index
		end

		get "/signup" do
			@bob = "hey sugar"
			erb :signup
		end
	end
end
