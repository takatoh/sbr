# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'httpclient'
require 'nokogiri'
require 'yaml'
require 'json'
require 'optparse'


module Sbr

  class PostPhotoCommand < Subcommand

    def initialize
      @options = {
        :repository => "",
        :source     => "",
        :page_url   => "",
        :tags       => "",
        :add_tags   => false,
        :input      => nil,
        :api        => false
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
      @parser.on('-A', '--add-tags', 'Add tags to be rejected. Use with -a option.'){|v| @options[:add_tags] = true}
      @parser.on('-a', '--use-api', 'Use API to post.'){|v| @options[:api] = true}
      @counter = {accepted: 0, rejected: 0, add_tags: 0, error: 0}
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
      puts "Accepted:   #{@counter[:accepted]}"
      puts "Rejected:   #{@counter[:rejected]}"
      puts "Added tags: #{@counter[:add_tags]}"
      puts "Error:      #{@counter[:error]}"
      puts "Total:      #{@counter[:accepted] + @counter[:rejected] + @counter[:error]}"
    end

    private

    def post_photo(photofile, opts = {})
      puts photofile
      File.open(photofile, "rb") do |file|
        post_data = {
          "url"      => opts["url"]      || @options[:source],
          "page_url" => opts["page_url"] || @options[:page_url],
          "tags"     => opts["tags"]     || @options[:tags],
          "add_tags" => opts["add_tags"],
          "file"     => file
        }
        post_url = if @options[:api]
          @options[:repository] + "api/post"
        else
          @options[:repository] + "post"
        end
        res = @hc.post(post_url, post_data)
        if @options[:api]
          result = JSON.parse(res.body)
          if result["status"] == "Accepted"
            puts "  => Accepted."
            @counter[:accepted] += 1
          elsif result["status"] == "Add tags"
            puts "  => Added tags: #{result["photo"]["addedTags"].join(" ")}"
            @counter[:add_tags] += 1
          else
            case result["reason"]
            when "Already exist"
              md5 = result["photo"]["md5"]
              puts "  => Rejected: Already exist(#{md5})."
              @counter[:rejected] += 1
            when "Small photo"
              puts "  => Rejected: Small photo."
              @counter[:rejected] += 1
            end
          end
        else
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
    end

    def photo?(file)
      %w(.jpg .jpeg .png .bmp .gif).include?(File.extname(file))
    end

  end

end
