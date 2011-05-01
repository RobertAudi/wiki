require "sinatra/base"
require "erb"
require "yaml"
require "bcrypt"
require "rdiscount"
require "rack-flash"

require_relative "wiki/page"
require_relative "wiki/user"

module Wiki
  class App < Sinatra::Base
    use Rack::MethodOverride
    use Rack::Flash

    configure do
      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
      set :app_file, __FILE__

      enable :sessions
      set :session_secret, "N0m d3 D13u d3 put41n d3 60rd31 d3 m3rd3 d3 s4l0pEri3 dE conN4rd d'EnculE d3 t4 m3r3"

      set :auth do |bool|
        condition do
          # remenber the previous route
          session[:route] = request.path_info
          unless logged_in?
            flash[:notice] = "You need to be logged in to access this page."
            redirect '/login'
          end
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

        flash[:success] = "Logged in successfully!"
        redirect (session[:route] || '/')
      else
        flash[:error] = "Failed to log in..."
        redirect 'login'
      end
    end

    get '/logout' do
      session[:user] = nil

      flash[:success] = "Logged out successfully!"
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
      page = Wiki::Page.new(params)
      page.save

      flash[:success] = "Page created successfully!"
      # FIXME: Redirect to the newly created page.
      redirect "/#{page.file.rpartition(".").fetch(0)}"
    end

    get '/:page' do
      page   = Page.get(params[:page], true)
      @title = page[:title]
      @body  = RDiscount.new(page[:body]).to_html

      erb :show
    end

    get '/:page/edit', :auth => true do
      page   = Page.get(params[:page])
      @title = page[:title]
      @body  = page[:body]

      erb :edit
    end

    put '/:page/edit', :auth => true do
      page  = Page.new(params)
      page.save(params["old_title"])

      flash[:success] = "Page edited successfully!"
      # redirect to the new page (assuming the page title changed)
      redirect "/#{page.file.rpartition(".").fetch(0)}"
    end

    get '/:page/delete', :auth => true do
      erb :delete
    end

    delete '/:page/delete', :auth => true do
      Page.delete!(params[:page])

      flash[:success] = "Page deleted successfully!"
      redirect "/"
    end
  end
end
