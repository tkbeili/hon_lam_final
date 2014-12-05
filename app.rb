=begin
HOW DO YOU RUN THIS FILE?
Install sinatra
The terminal command is "ruby app.rb"
=end

# Make sure you intall these gems
require "sinatra"
require "pony"
require "data_mapper"
require "dm-sqlite-adapter"
# dm-sqlite-adapter 
# These lines make the Ruby gems required"

DataMapper::setup(:default,ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/contact.db")
# DataMapper will lok for a table named contacts
# DataMapper is a module
# DataMapper was installed using this command: gem install data_mapper
# The || accomodates for Heroku

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end
end
# These method protects the information. They are taken from Sinatra FAQ. Some methods below will call the protected! method.

enable :sessions

class Contact
	# The table will be called Contact
	include DataMapper::Resource

	property :id, Serial
	property :name, String
	property :email, String
	property :design, String
	property :content, String
	property :speed, String
	property :overall, String
	# These are the same as from the web form

end

use Rack::MethodOverride
# This is a work-around. The <form> cannot use "patch" or "delete" as actions. Instead, there is a hidden INPUT field that specifies PATCH or DELETE.

Contact.auto_upgrade!
# Creates table if doesn't exit. Adds columns if don't exist

# get -> HTTP verb
# "/" -> URL

get "/contact" do

	erb :contact, layout: :default
end

post "/confirm" do
	Contact.create(
		name: params[:name],
		email: params[:email],
		design: params[:design],
		content: params[:content],
		speed: params[:speed],
		overall: params[:overall]
		)

	Pony.mail(to: "#{params[:email]}",
		from: "Rate my website",
		reply_to: "lamh85@gmail.com",
		subject: "We received your rating!",
		body: "This email is to confirm that we have received your rating!",
		via: :smtp,
		via_options: {
              address: "smtp.gmail.com",
              port: "587",
              user_name: "answerawesome",
              password: "Sup3r$ecret",
              authentication: :plain,
              enable_starttls_auto: true
#answerawesome
#Sup3r$ecret
            }
		)

	erb :confirm, layout: :default
end

get "/" do
	protected!	
	@contacts = Contact.all
	erb :index, layout: :default
end