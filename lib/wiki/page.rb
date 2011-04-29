require "fileutils"

module Wiki
  class Page
    attr_reader :title, :filename
    attr_accessor :body
    @@data_dir = ""

    def initialize(title = "", body = "")
      set_data_dir

      @filename = ""
      @filepath = ""

      unless title.nil? || title.empty?
        @title = title
      end

      @body = body
    end

    def save
      raise "Invalid title" unless validate(title)
      @filename = slugalize(title) + ".markdown"
      @filepath = File.join(@@data_dir, @filename)
      
      File.open(@filepath, "w") do |f|
        f.puts body
      end
    end

    def remove_old_file!(old_title, new_title)
      return if old_title == new_title

      old_filename = slugalize(old_title) + ".markdown"
      old_filepath = File.join(@@data_dir, old_filename)
      if File.exists?(old_filepath)
        File.delete(old_filepath)
      end
    end

    def self.list
      data_dir = File.join(ENV['HOME'], ".wiki", "pages")
      list     = Dir.glob(data_dir + "/*.markdown")
      pages    = []

      list.each do |page|
        slug  = page.rpartition("/").last.split(".").first
        title = humanize slug

        pages << { slug: slug, title: title }
      end

      pages
    end

    def self.get(page)
      data_dir = File.join(ENV['HOME'], ".wiki", "pages")
      page = File.join(data_dir, page + ".markdown")
      
      body = ""
      if File.exists?(page)
        body = File.read(page)
      else
        body = "This page doesn't exist yet!"
      end

      slug  = page.rpartition("/").last.split(".").first
      title = humanize slug
      
      { title: title, body: body }
    end

    def self.delete!(page)
      data_dir = File.join(ENV['HOME'], ".wiki", "pages")
      page = File.join(data_dir, page + ".markdown")
      
      if File.exists?(page)
        File.delete(page)
      end
    end

    def file
      @filename
    end

    def data_dir
      @@data_dir
    end

    def self.data_dir
      @@data_dir
    end

    def title=(title)
      raise unless validate(title)
      @title
    end

    private

    def set_data_dir
      data_dir = File.join(ENV['HOME'], ".wiki", "pages")
      if Dir.exists?(data_dir)
        @@data_dir = data_dir if @@data_dir.empty?
      else
        FileUtils.mkdir_p(data_dir)
        @@data_dir = data_dir
      end

      @@data_dir
    end

    def validate(title)
      unless title.is_a?(String) && !title.empty?
        return false
      end

      @title = title
    end

    def slugalize(title)
      title.gsub!(/[^a-z0-9-]+/i, '-')
      title.gsub!(/-{2,}/, '-')
      title.gsub!(/^-|-$/, '')
      title.downcase!
      title
    end

    def self.humanize(title)
      title.gsub(/-/, " ").capitalize
    end


  end
end
