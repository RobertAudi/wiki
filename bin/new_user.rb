require 'bcrypt'
require 'yaml'

# ------------------------------------------------------------------------------

puts "A new user will now be generated. Press Ctrl-C at any time to stop the process."

# -User Input-------------------------------------------------------------------
user = {}

# Get the username
print "Username: "
user[:username] = gets.chomp

if user[:username].empty?
  $stderr.puts "\nERROR: Username can't be blank"
  exit
end

# Get the password
system 'stty -echo' # Typed characters won't appear
print "Password: "
password = gets.chomp
system 'stty echo' # Revert to default.

if password.empty?
  $stderr.puts "\nERROR: Password can't be blank"
  exit
else
  user[:password] = BCrypt::Password.create(password).to_s
  print "[Password]\n----\n"
end
# ------------------------------------------------------------------------------

# Create the temporary config file
f = File.new(File.join(File.dirname(__FILE__), '../config/user.sample.yml'), 'w')
f.puts user.to_yaml
f.close

puts "\n\t[New File] config/user.sample.yml\n\n"
puts "Please review the file and rename it to user.yml"
# ------------------------------------------------------------------------------

