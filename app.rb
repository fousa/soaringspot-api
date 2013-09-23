require 'rubygems'
require 'sinatra'
require 'json'

require './soaring_spot'

class App < Sinatra::Base
    set :root, File.dirname(__FILE__)

    get '/' do
        redirect "/api/competitions"
    end

    get '/api/competitions' do
        content_type :json, 'charset' => 'utf-8'
        status 200
        if params[:country].nil? || params[:year].nil?
            SoaringSpot.new.competitions.to_json
        else
            SoaringSpot.new.filtered_competitions(params[:country], params[:year]).to_json
        end
    end

    get '/api/competitions/:code' do
        content_type :json, 'charset' => 'utf-8'
        if params[:code].nil?
            status 400
        else
            status 200
            SoaringSpot.new.competition(params[:code]).to_json
        end
    end

    get '/api/competitions/:code/classes/:class/pilots' do
        content_type :json, 'charset' => 'utf-8'
        if params[:code].nil? || params[:class].nil?
            status 400
        else
            status 200
            SoaringSpot.new.pilots(params[:code], params[:class]).to_json
        end
    end

    get '/api/competitions/:code/classes/:class/days/:day' do
        content_type :json, 'charset' => 'utf-8'
        if params[:code].nil? || params[:class].nil? || params[:day].nil?
            status 400
        else
            status 200
            SoaringSpot.new.day(params[:code], params[:class], params[:day]).to_json
        end
    end

    run! if app_file == $0

    private

    def process_json(objects)
        status 200
        objects.to_json
    end
end
