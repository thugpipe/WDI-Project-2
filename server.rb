require "sinatra"
require "bcrypt"
require "pg"
require "pry"
require "redcarpet"

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
			session["current_page"] = "/"

			erb :index
		end

		get "/topic/:id" do
			@status = session["user_id"]
			@id = params[:id].to_i
			@thread = @@db.exec("SELECT topic FROM threads WHERE id = #{@id}").first
			@posts = @@db.exec("SELECT posts.id, title, content, created_by_id, thread_id, username FROM posts INNER JOIN users ON (users.id = posts.created_by_id) WHERE thread_id = #{@id}").to_a
			# @posts = @@db.exec("SELECT * FROM posts WHERE thread_id = #{@id}").to_a
			session["current_page"] = "/topic/#{@id}"
			erb :topic
		end

		post "/topic" do
			markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

			topic_id = params["topic_id"]
			title = params["title"]
			content = markdown.render(params["content"])
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
					redirect session["current_page"]
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
				session["current_page"] = "/login"
				redirect '/login'
		end

		get "/post/:id" do
			@status = session["user_id"]
			@id = params[:id].to_i
			@post = @@db.exec("SELECT * FROM posts WHERE id = #{@id}").first
			if @status
				@user_liked = @@db.exec("SELECT * FROM likes WHERE post_id = #{@id} AND user_id = #{@status}").to_a
			else
				@user_liked = []
			end
			@num_likes = @@db.exec("SELECT * FROM likes WHERE post_id = #{@id}").to_a.length
			@comments = @@db.exec("SELECT comments.id, user_id, content, username FROM comments INNER JOIN users ON (comments.user_id = users.id) WHERE post_id = #{@id}").to_a
			# @posts = @@db.exec("SELECT * FROM posts WHERE thread_id = #{@id}").to_a
			session["current_page"] = "/post/#{@id}"

			erb :post

		end

		post "/post" do
			post_id = params["post_id"]
			comment = params["comment"]
			user_id = params["user_id"]

			@@db.exec_params("INSERT INTO comments (post_id, user_id, content) VALUES ($1,$2,$3)",[post_id, user_id, comment])

			redirect '/post/' + post_id

		end

		post "/like" do
			post_id = params["post_id"]
			user_id = params["user_id"]

			@@db.exec_params("INSERT INTO likes (user_id, post_id) VALUES ($1,$2)",[user_id, post_id])

			redirect '/post/' + post_id
		end
	end
end
