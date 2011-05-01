require_relative "spec_helper"
require_relative "../lib/wiki/page"

describe "Page" do
  describe "The class and the constructor" do
    it "should have a valid data directory" do
      page = Wiki::Page.new

      File.directory?(Wiki::Page.data_dir).must_equal true
      File.directory?(page.data_dir).must_equal true
      Wiki::Page.data_dir.must_equal page.data_dir
    end

    it "should raise an exception if the argument passed to the constructor is not a String or a Hash" do
      [:forty_two, 42, [42], 42.0, 0..42].each do |arg|
        lambda do
          page = Wiki::Page.new(arg)
        end.must_raise ArgumentError
      end
    end

    it "should set the title if a String was passed as argument to the constructor" do
      the_title = "This is the title"
      page = Wiki::Page.new(the_title)

      page.title.must_equal the_title
    end

    it "should set the right attributes if a hash was passed as argument to the constructor" do
      params = {
        "title" => "This is the title",
        "body"  =>  "This is the body"
      }
      page = Wiki::Page.new(params)

      page.title.must_equal params["title"]
      page.body.must_equal params["body"]
    end
  end

  describe "The page object" do
    before do
      @page = Wiki::Page.new
      @title = "This is the title"
      @page.title = @title
      @page.save
    end

    after do
      Wiki::Page.delete!(Wiki::Page.slugalize(@title))
    end

    it "should have a title" do
      @page.title.must_equal @title
    end

    it "should have a body" do
      body = "This is a blank page"

      @page.body  = body
      @page.save

      @page.body.must_equal body
    end

    it "should take the title from the body if it's available" do
      @page.body = "# This is the NEW title"
      @page.save

      get "/#{Wiki::Page.slugalize(@page.title)}"
      response = Nokogiri::HTML(last_response.body)

      response.css("h1#title").first.text.must_equal "This is the NEW title"
      response.css("section#page").first.text.must_equal ""
    end

    it "should create the page file with the correct name" do
      @page.file.must_equal "this-is-the-title.markdown"
      File.exists?(File.join(@page.data_dir, @page.file)).must_equal true
    end

  end

  describe "The deletions" do
    describe "edit" do
      before do
        @page = Wiki::Page.new
        @old_title = "This is the title"
        @new_title = "This is the new title"
        @page.title = @old_title
        @page.save
        @page.title = @new_title
        @page.save(@old_title)
      end

      after do
        Wiki::Page.delete!(@old_title)
        Wiki::Page.delete!(@new_title)
      end

      it "should rename the file when the title changes" do
        page = Wiki::Page.new
        old_title = "This is the title"
        page.title = old_title
        page.save

        the_title = "This is the new title"
        page.title = the_title
        page.save(old_title)

        File.exists?(File.join(page.data_dir, "#{Wiki::Page.slugalize(old_title)}.markdown")).must_equal false
      end
    end

    describe "delete" do
      it "should delete the page" do
        the_title = "This is the title"
        page = Wiki::Page.new
        page.title = the_title
        page.save

        the_slug = Wiki::Page.slugalize(the_title)
        Wiki::Page.delete!(the_slug)

        File.exists?(File.join(page.data_dir, the_slug + ".markdown")).must_equal false
      end
    end
  end
end
