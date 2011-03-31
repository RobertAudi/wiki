require 'autowatchr'

APP_NAME = "wiki"

Autowatchr.new(self) do |config|
  config.test_dir = 'spec'
  config.test_re = "^#{config.test_dir}/(.*)_spec\.rb$"
  config.test_file = '%s_spec.rb'
end

def run_spec(file)
  unless File.exists?(file)
    puts "#{file} does not exist!"
    return
  end

  puts "Running #{file}"
  system "ruby #{file}"
  puts
end

watch("spec/.*_spec\.rb") do |match|
  run_spec match[0]
end

watch("lib/#{APP_NAME}/(.*)\.rb") do |match|
  run_spec %{spec/#{match[1]}_spec.rb}
end

watch("lib/#{APP_NAME}/algo/(.*)\.rb") do |match|
  run_spec %{spec/algo/#{match[1]}_spec.rb}
end