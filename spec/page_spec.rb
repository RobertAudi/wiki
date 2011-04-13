require_relative "spec_helper"
require_relative "../lib/wiki/page"

describe "Page" do

  it "should have a valid data directory" do
    page = Wiki::Page.new("This is the title")
    
    File.directory?(Wiki::Page.data_dir).must_equal true
    File.directory?(page.data_dir).must_equal true
    Wiki::Page.data_dir.must_equal page.data_dir
  end

  it "should have a title" do
    the_title = "This is the title"
    
    page = Wiki::Page.new
    page.title = the_title
    page.save
    
    page.title.must_equal the_title
  end
  
  it "should have a body" do
    the_body = "This is a blank page"
    
    page = Wiki::Page.new
    page.title = "The title"
    page.body  = the_body
    page.save
    
    page.body.must_equal the_body
  end
  
  it "should create the page file with the correct name" do
    page = Wiki::Page.new
    page.title = "This is the title"
    page.save
    
    page.file.must_equal "this-is-the-title.markdown"
    File.exists?(File.join(page.data_dir, page.file)).must_equal true
  end

end