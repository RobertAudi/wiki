require "sinatra/base"
require "erb"
require "bcrypt"

require_relative "wiki/page"
require_relative "wiki/user"

module Wiki
  class App < Sinatra::Base
    use Rack::MethodOverride

    configure do
      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
      set :app_file, __FILE__
      set :sessions
      
      set :auth do |bool|
        condition do
          redirect '/login' unless logged_in?
        end
      end
    end
    
    helpers do
      def logged_in?
        not @user.nil?
      end
    end

    before do
      @user = session[:user]
      p @user
    end

    get '/login/?' do
      erb :login
    end

    post '/login' do
      user = Wiki::User.get
      if user.authenticate(params[:username], params[:password])
        session[:user] = params[:username]
        redirect '/'
      end
    end

    get '/', :auth => true do
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
