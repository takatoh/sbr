# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'httpclient'
require 'nokogiri'
require 'yaml'
require 'optparse'


module Sbr

  class PostPhotoCommand < Subcommand

    def initialize
      @options = {
        :repository => "",
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
      @parser.on('-p', '--page_url=URL', 'Set webpage url.'){|v| @options[:page_url] = v}
      @parser.on('-t', '--tags=TAGS', 'Set tags.'){|v| @options[:tags] = v}
      @parser.on('-i', '--input=YAML', 'Post photo in YAML indtead photofile.'){|v| @options[:input] = v}
      @counter = {accepted: 0, rejected: 0, error: 0}
    end

    def exec(argv)
      photofile = argv.shift
      @hc = HTTPClient.new
      if @options[:input]
        photos = YAML.load_file(@options[:input])
        photos.each do |photo|
          if File.exist?(photo["file"])
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
      puts "Accepted: #{@counter[:accepted]}"
      puts "Rejected: #{@counter[:rejected]}"
      puts "Error:    #{@counter[:error]}"
      puts "Total:    #{@counter[:accepted] + @counter[:rejected] + @counter[:error]}"
    end

    private

    def post_photo(photofile, opts = {})
      puts photofile
      File.open(photofile, "rb") do |file|
        post_data = {
          "url"      => opts["url"]      || @options[:source],
          "page_url" => opts["page_url"] || @options[:page_url],
          "tags"     => opts["tags"]     || @options[:tags],
          "file"     => file
        }
        res = @hc.post(@options[:repository] + "post", post_data)
        doc = Nokogiri::HTML.parse(res.body)
        result = doc.search("h3").text
        if result =~ /Rejected/
          puts "  => #{result.gsub("\n", "").gsub(/ +/, " ").strip}"
          @counter[:rejected] += 1
        else
          puts "  => Accepted."
          @counter[:accepted] += 1
        end
      end
    end

    def photo?(file)
      %w(.jpg .jpeg .png .bmp .gif).include?(File.extname(file))
    end

  end

end
