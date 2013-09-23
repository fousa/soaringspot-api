require 'rubygems'
require 'sinatra'
require 'json'
require 'haml'

require './soaring_spot'

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

        soaring_spot = SoaringSpot.new 
        soaring_spot.competitions.to_json
    end

    get '/competitions/filter/:country/:year' do
        content_type :json, 'charset' => 'utf-8'

        soaring_spot = SoaringSpot.new 
        soaring_spot.filtered_competitions(params[:country], params[:year]).to_json
    end

    get '/competitions/:code/results' do
        content_type :json, 'charset' => 'utf-8'

        soaring_spot = SoaringSpot.new 
        soaring_spot.competition(params[:code]).to_json
    end

    get '/competitions/:code/results/:klass/pilots' do
        content_type :json, 'charset' => 'utf-8'

        soaring_spot = SoaringSpot.new 
        soaring_spot.pilots(params[:code], params[:klass]).to_json
    end

    get '/competitions/:code/results/:klass/days/:day' do
        content_type :json, 'charset' => 'utf-8'

        soaring_spot = SoaringSpot.new 
        soaring_spot.day(params[:code], params[:klass], params[:day]).to_json
    end

    # start the server if ruby file executed directly
    run! if app_file == $0
end
