require "sinatra/base"
require "erb"

require_relative "wiki/page"

module Wiki
  class App < Sinatra::Base
    use Rack::MethodOverride

    configure do
      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
      set :app_file, __FILE__
    end

    get '/' do
      @pages = Wiki::Page.list
      erb :list
    end

    get '/create' do
      erb :create
    end

    post '/create' do
      page = Wiki::Page.new(params[:title], params[:body])
      page.save

      redirect "/"
    end

    get '/:page' do
      page   = Page.get(params[:page])
      @title = page[:title]
      @body  = page[:body] # FIXME: Render the markdown page in html?
      erb :show
    end

    get '/:page/edit' do
      page   = Page.get(params[:page])
      @title = page[:title]
      @body  = page[:body]
      
      erb :edit
    end

    put '/:page/edit' do
      page  = Page.new(params[:title], params[:body])
      page.save

      redirect "/#{params[:page]}"
    end

    get '/:page/delete' do
      erb :delete
    end

    delete '/:page/delete' do
      Page.delete!(params[:page])
      
      redirect "/"
    end
  end
end
