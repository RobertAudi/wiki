require "fileutils"

module Wiki
  class Page
    attr_reader :title
    attr_accessor :body
    @@data_dir = ""

    def initialize(params = {})
      if params.is_a?(String)
        title = params
      elsif params.is_a?(Hash)
        unless params.empty?
          ["title", "body"].each do |attr|
            if params.include?(attr)
              method = (attr.to_s + "=").to_sym
              send(method, params[attr])
            end
          end
        end
      else
        raise ArgumentError
      end

      Wiki::Page.set_data_dir

      @filename = ""
      @filepath = ""

      unless title.nil? || title.empty?
        @title = title
      end

      @body = body
    end

    def save(old_title = nil)
      # First step is to delete the old page file if there is one
      if old_title
        old_filename = Wiki::Page.slugalize(old_title)
        Wiki::Page.delete!(old_filename)
      end

      raise "Invalid title" unless validate(title)
      @filename = Wiki::Page.slugalize(title) + ".markdown"
      @filepath = File.join(@@data_dir, @filename)

      File.open(@filepath, "w") do |f|
        f.puts body
      end
    end

    def self.list
      data_dir = File.join(ENV['HOME'], "Dropbox", "wiki", "pages")
      list     = Dir.glob(data_dir + "/*.markdown")
      pages    = []

      list.each do |page|
        slug  = page.rpartition("/").last.split(".").first
        title = humanize slug

        pages << { slug: slug, title: title }
      end

      pages
    end

    def self.get(page, get_title_from_body = false)
      data_dir = File.join(ENV['HOME'], "Dropbox", "wiki", "pages")
      page = File.join(data_dir, page + ".markdown")

      if File.exists?(page)
        body = File.read(page)
      else
        body = "This page doesn't exist yet!"
      end

      slug  = page.rpartition("/").last.split(".").first
      if get_title_from_body
        p = get_title_from(body)
        if p
          title = p[:title]
          body  = p[:body]
        else
          title = humanize(slug)
        end
      else
        title = humanize(slug)
      end

      { title: title, body: body }
    end

    def self.delete!(page)
      data_dir = File.join(ENV['HOME'], "Dropbox", "wiki", "pages")
      page = File.join(data_dir, page + ".markdown")

      if File.exists?(page)
        File.delete(page)
      end
    end

    def file
      @filename
    end

    def data_dir
      Wiki::Page.set_data_dir
    end

    # what if the data dir doesn't exist....
    def self.data_dir
      set_data_dir
    end

    def title=(title)
      raise unless validate(title)
      @title
    end

    def self.slugalize(title)
      title.gsub!(/[^a-z0-9-]+/i, '-')
      title.gsub!(/-{2,}/, '-')
      title.gsub!(/^-|-$/, '')
      title.downcase!
      title
    end

    def self.humanize(title)
      title.gsub(/-/, " ").capitalize
    end

    # -Private-Methods--------------------------------------------------------------
    private

    def self.set_data_dir
      return @@data_dir unless @@data_dir.empty?

      data_dir = File.join(ENV['HOME'], "Dropbox", "wiki", "pages")
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

    def self.get_title_from(body)
      lines = body.split("\n")
      title = lines[0..1]

      return false if title.nil? || title.empty?

      if title.last =~ /^={3,}(?:\n)?$/
        title = title.first unless title.first.strip =~ /^\#{1} /
        body = lines[2..-1].join
        return { title: title, body: body }
      elsif title.first.strip =~ /^\#{1} /
        body = lines[1..-1].join
        title = title.first[1..-1].strip unless title.last =~ /^={3,}(?:\n)?$/
        return { title: title, body: body }
      end

      return false
    end
  end
end
