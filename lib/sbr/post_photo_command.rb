# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'httpclient'
require 'yaml'
require 'optparse'


module Sbr

  class PostPhotoCommand < Subcommand

    def initialize
      super
      @options = {
        :repository => @config["repository"],
        :source     => "",
        :page_url   => "",
        :tags       => "",
        :input      => nil
      }
      @parser = OptionParser.new
      @parser.banner =<<EOB
  #{@parser.program_name} post - Post photo(s).
  Usage: #{@parser.program_name} post [options] <photofile>
EOB
      @parser.on('-R', '--repository=URL', 'Set repository url.'){|v| @options[:repository] = v}
      @parser.on('-s', '--source=SOURCE', 'Set source of photo.'){|v| @options[:source] = v}
      @parser.on('-p', '--page-url=URL', 'Set webpage url.'){|v| @options[:page_url] = v}
      @parser.on('-t', '--tags=TAGS', 'Set tags.'){|v| @options[:tags] = v}
      @parser.on('-i', '--input=YAML', 'Post photo in YAML indtead photofile.'){|v| @options[:input] = v}
      @parser.on('-a', '--add-tags', 'Add tags to be rejected.'){|v| @options[:add_tags] = true}
      @counter = {accepted: 0, rejected: 0, added_tags: 0, error: 0}
    end

    def exec(argv)
      photofile = argv.shift
      @hc = HTTPClient.new
      if @options[:input]
        photos = YAML.load_file(@options[:input])
        photos.each do |photo|
          if File.exist?(photo["file"])
            if @options[:tags]
              photo["tags"] = (photo["tags"] + " " + @options[:tags]).strip
            end
            post_photo(photo["file"], photo)
          else
            puts photo["file"]
            puts "  => Error(Skip): File not found."
            @counter[:error] += 1
          end
        end
      elsif File.file?(photofile)
        post_photo(photofile)
      elsif File.directory?(photofile)
        Dir.glob("#{photofile}/*.*").each do |f|
          if photo?(f)
            post_photo(f)
          end
        end
      end
      puts ""
      puts "Accepted:   #{@counter[:accepted]}"
      puts "Rejected:   #{@counter[:rejected]}"
      puts "Added tags: #{@counter[:added_tags]}"
      puts "Error:      #{@counter[:error]}"
      puts "Total:      #{@counter[:accepted] + @counter[:rejected] + @counter[:added_tags] + @counter[:error]}"
    end

  end

end
