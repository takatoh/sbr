# -*- encoding: utf-8 -*-


require 'json'
require 'yaml'


module Sbr

  class Subcommand

    def initialize
      @config_file = "#{ENV["HOME"]}/.sbrconfig.yml"
      begin
        @config = YAML.load_file(@config_file)
      rescue
        @config = {}
      end
    end

    def parse(argv)
      begin
        @parser.parse!(argv)
      rescue OptionParser::ParseError => err
        $stderr.puts err.message
        $stderr.puts @parser.help
        exit 1
      end
    end

    def help
      @parser.help
    end

    private

    def post_photo(photofile, opts = {})
      puts photofile
      post_data = {
        "url"      => opts["url"]      || @options[:source],
        "page_url" => opts["page_url"] || @options[:page_url],
        "tags"     => opts["tags"]     || @options[:tags],
        "file"     => HTTP::FormData::File.new(photofile)
      }
      post_data["add_tags"] = true if opts["add_tags"] || @options[:add_tags]
      post_url = @options[:repository] + "api/post"
      res = HTTP.post(post_url, :form => post_data)
      result = JSON.parse(res.to_s)
      if result["status"] == "Accepted"
        photo = result["photo"]
        puts "  => Accepted: id=#{photo['id']} size=#{photo['width']}x#{photo['height']}"
        @counter[:accepted] += 1
      elsif result["status"] == "Added tags"
        photo = result["photo"]
        puts "  => Added tags: #{photo["addedTags"].join(" ")} (id=#{photo['id']})"
        @counter[:added_tags] += 1
      else
        case result["reason"]
        when "Already exist"
          photo = result["photo"]
          puts "  => Rejected: Already exist(id=#{photo['id']})"
          @counter[:rejected] += 1
        when "Small photo"
          puts "  => Rejected: Small photo"
          @counter[:rejected] += 1
        end
      end
    end

    def clip_photo(photourl, opts = {})
      puts photourl
      post_data = {
        "url"      => photourl,
        "page_url" => opts["page_url"],
        "tags"     => opts["tags"],
        "add_tags" => opts["add_tags"],
        "force"    => opts["force"]
      }
      post_url = @options[:repository] + "api/clip"
      res = HTTP.post(post_url, :form => post_data)
      result = JSON.parse(res.to_s)
      if result["status"] == "Accepted"
        photo = result["photo"]
        puts "  => Accepted: id=#{photo['id']} size=#{photo['width']}x#{photo['height']}"
        @counter[:accepted] += 1
      elsif result["status"] == "Added tags"
        photo = result["photo"]
        puts "  => Added tags: #{photo["addedTags"].join(" ")} (id=#{photo['id']})"
        @counter[:added_tags] += 1
      else
        case result["reason"]
        when "Already exist"
          photo = result["photo"]
          puts "  => Rejected: Already exist(id=#{photo['id']})"
          @counter[:rejected] += 1
        when "Small photo"
          puts "  => Rejected: Small photo"
          @counter[:rejected] += 1
        end
      end
    end

    def photo?(file)
      %w(.jpg .jpeg .png .bmp .gif).include?(File.extname(file))
    end

  end

end
