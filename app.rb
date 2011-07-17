require 'rubygems'
require 'sinatra'
require 'json'
require 'haml'
require 'soaring_spot'
require 'mongoid'
require 'stat'

configure :production do
	Mongoid.load!("config/mongoid.yml")
end

configure :development do
	Mongoid.configure do |config|
    name = "demo"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
    config.slaves = [
      Mongo::Connection.new(host, 27017, :slave_ok => true).db(name)
    ]
    config.persist_in_safe_mode = false
  end
end

class App < Sinatra::Base
	set :root, File.dirname(__FILE__)

  get '/' do
		redirect "/competitions"
  end
	
	get '/stats' do
		haml :stats
	end

	get '/competitions' do
    content_type :json, 'charset' => 'utf-8'

		stat = Stat.find_or_create_by( :name => "all_competitions")
		stat.update_attribute :total_calls, (stat.total_calls || 0) + 1
		
		soaring_spot = SoaringSpot.new 
		
    soaring_spot.competitions.to_json
	end

	get '/competitions/:code/results' do
    content_type :json, 'charset' => 'utf-8'

		stat = Stat.find_or_create_by( :name => "competitions-#{params[:code]}")
		stat.update_attribute :total_calls, (stat.total_calls || 0) + 1

		soaring_spot = SoaringSpot.new 
		
    soaring_spot.competition(params[:code]).to_json
	end

	get '/competitions/:code/results/:klass/pilots' do
    content_type :json, 'charset' => 'utf-8'

		stat = Stat.find_or_create_by( :name => "competitions-#{params[:code]}-klass-pilots")
		stat.update_attribute :total_calls, (stat.total_calls || 0) + 1

		soaring_spot = SoaringSpot.new 
		
    soaring_spot.pilots(params[:code], params[:klass]).to_json
	end

	get '/competitions/:code/results/:klass/days/:day' do
    content_type :json, 'charset' => 'utf-8'

		stat = Stat.find_or_create_by( :name => "competitions-#{params[:code]}-klass-day-#{params[:day]}")
		stat.update_attribute :total_calls, (stat.total_calls || 0) + 1

		soaring_spot = SoaringSpot.new 
		
    soaring_spot.day(params[:code], params[:klass], params[:day]).to_json
	end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
