require "sinatra"
require "bcrypt"
require "pg"
require "pry"
module Forum
	class Server <Sinatra::Base
		enable :sessions

		@@db = PG.connect({dbname: "compact_living_dev"})

		def current_user
			@user = @@db.exec_params("SELECT * FROM users WHERE id = $1",[session["user_id"]]).first 
		end
		
		get "/" do
			@status = session["user_id"]
			@threads = @@db.exec("SELECT * FROM threads").to_a

			erb :index
		end

		get "/topic/:id" do
			@status = session["user_id"]
			@id = params[:id].to_i
			@thread = @@db.exec("SELECT topic FROM threads WHERE id = #{@id}").first
			@posts = @@db.exec("SELECT * FROM posts INNER JOIN users ON (posts.created_by_id = users.id) WHERE thread_id = #{@id}").to_a
			# @posts = @@db.exec("SELECT * FROM posts WHERE thread_id = #{@id}").to_a

			erb :topic
		end

		post "/topic" do
			topic_id = params["topic_id"]
			title = params["title"]
			content = params["content"]
			user_id = params["user_id"]

			@@db.exec_params("INSERT INTO posts (title, content, created_by_id, thread_id) VALUES ($1,$2,$3,$4)",[title, content, user_id, topic_id])

			redirect '/topic/' + topic_id

		end

		get "/signup" do
			@status = session["user_id"]
			erb :signup
		end

		post "/signup" do
			name = params["name"]
			username = params["login_name"]
			encrypted_password = BCrypt::Password.create(params["login_password"])

			@@db.exec_params("INSERT INTO users (name, username, password_digest) VALUES ($1,$2,$3)", [name, username, encrypted_password])
			redirect '/login'
		end

		get "/login" do
			@status = session["user_id"]
			erb :login
		end

		post "/login" do
			user_name = params['login_name']
			login_password = params["login_password"]

			@user = @@db.exec_params("SELECT * FROM users WHERE username = $1",[user_name]).first

			if @user
				if BCrypt::Password.new(@user["password_digest"]) == login_password
					session["user_id"] = @user["id"]
					@login_status = "#{@user["username"]} you are logged in!"
					redirect '/login'
				else
					@login_status = "Invalid password"
					erb :login
				end
			else
				@login_status = "Invalid username"
				erb :login
			end
		end

		get "/logout" do
				session["user_id"] = false
				redirect '/login'
		end

		get "/post/:id" do
			@status = session["user_id"]
			@id = params[:id].to_i
			@post = @@db.exec("SELECT post FROM posts WHERE id = #{@id}").first
			@comments = @@db.exec("SELECT * FROM comments WHERE post_id = #{@id}").to_a
			# @posts = @@db.exec("SELECT * FROM posts WHERE thread_id = #{@id}").to_a

			erb :topic

		end
	end
end
