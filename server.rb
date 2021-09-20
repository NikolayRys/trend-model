require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/json'
require 'sinatra/namespace'

require_relative 'model.rb'

class Backend < Sinatra::Application
  use Rollbar::Middleware::Sinatra
  set :environment, ENV['RACK_ENV']

  config_file 'config/config.yml'

  namespace '/api' do
    get '' do
      json message: 'Main API route'
    end

    post '/reddit-trend' do
      response.headers['Access-Control-Allow-Origin'] = '*'
      google_response = begin
        request.body.rewind
        query_data = Model.get_estimate(request.body.read)
      rescue => error
        "Sent: \n" + query_data + "\n" + error.message + "\n" + error.backtrace.inspect
      end
      json google_response
    end
    options "/reddit-trend" do
      response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
      200
    end
  end

  not_found do
    status 404
    json error: 'Page not found'
  end
end

