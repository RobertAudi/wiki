require_relative "../lib/wiki"

# use the minitest gem, not the one
# included in the Ruby Standard Library
gem "minitest"
require "minitest/spec"
require "minitest/pride"
require "redgreen"
require "rack/test"
require "nokogiri"

# Necessary to make rack-test work
ENV['RACK_ENV'] = "test"

MiniTest::Unit.autorun
include Rack::Test::Methods

def app
  Wiki::App
end