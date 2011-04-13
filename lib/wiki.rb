require "sinatra/base"
require "erb"

module Wiki
  class App < Sinatra::Base
    use Rack::MethodOverride

    configure do
      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..'))
      set :app_file, __FILE__
    end
    
    get '/' do
      erb :wiki
    end
  end
end
