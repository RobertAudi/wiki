module Wiki
  class User
    def initialize(args = {})
      @username = args[:username]
      @password = args[:password]
    end
    
    def self.get
      User.new(YAML::load(File.open('config/user.yml')))
    end
    
    def authenticate(username = nil, password = nil)
       return false if username.nil? || username.empty?
       return false if password.nil? || password.empty?

       return false unless @username == username
       return false unless BCrypt::Password.new(@password) == password

       return true
     end
  end
end