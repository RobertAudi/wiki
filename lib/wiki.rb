require "sinatra/base"
require "erb"
require "yaml"
require "bcrypt"
require "rdiscount"

require_relative "wiki/page"
require_relative "wiki/user"

module Wiki
  class App < Sinatra::Base
    use Rack::MethodOverride

    configure do
      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
      set :app_file, __FILE__

      enable :sessions
      set :session_secret, "N0m d3 D13u d3 put41n d3 60rd31 d3 m3rd3 d3 s4l0pEri3 dE conN4rd d'EnculE d3 t4 m3r3"

      set :auth do |bool|
        condition do
          # remenber the previous route
          session[:route] = request.path_info
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
      unless request.path_info =~ /login/
        session[:route] = nil
      end
    end

    get '/login/?' do
      if logged_in?
        redirect '/'
      else
        erb :login
      end
    end

    post '/login' do
      user = Wiki::User.get
      if user.authenticate(params[:username], params[:password])
        session[:user] = params[:username]
        redirect (session[:route] || '/')
      end
    end

    get '/logout' do
      session[:user] = nil
      redirect '/'
    end

    get '/' do
      @pages = Wiki::Page.list
      erb :list
    end

    get '/create', :auth => true do
      erb :create
    end

    post '/create', :auth => true do
      page = Wiki::Page.new(params[:title], params[:body])
      page.save

      redirect "/"
    end

    get '/:page' do
      page   = Page.get(params[:page])
      @title = page[:title]
      @body  = RDiscount.new(page[:body]).to_html
      erb :show
    end

    get '/:page/edit', :auth => true do
      page   = Page.get(params[:page])
      session[:old_title] = page[:title]
      @title = page[:title]
      @body  = page[:body]

      erb :edit
    end

    put '/:page/edit', :auth => true do
      page  = Page.new(params[:title], params[:body])

      # if old_title and title are not the same the page file will be deleted!
      page.remove_old_file!(session[:old_title], params[:title])
      session[:old_title] = nil
      page.save

      # redirect to the new page (assuming the page title changed)
      redirect "/#{page.filename.rpartition(".").fetch(0)}"
    end

    get '/:page/delete', :auth => true do
      erb :delete
    end

    delete '/:page/delete', :auth => true do
      Page.delete!(params[:page])

      redirect "/"
    end
  end
end
