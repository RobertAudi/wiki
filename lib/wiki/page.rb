require "fileutils"

module Wiki
  class Page
    attr_reader :title
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
      @filename = title + ".markdown"
      @filepath = File.join(@@data_dir, @filename)

      if File.exists?(@filepath)
        
      else
        File.open(@filepath, "w") do |f|
          f.puts body
        end
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
      @title = slugalize title
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

  end
end