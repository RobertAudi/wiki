require_relative "spec_helper"

describe "Wiki::App" do

  it "should have the right title" do
    get "/"
    response = Nokogiri::HTML(last_response.body).css('title')
    response.first.text.wont_be_empty
    response.length.must_equal 1

    response.each do |title|
      title.text.strip.must_equal "Wiki"
    end
  end

end
