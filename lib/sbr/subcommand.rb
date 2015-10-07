# -*- encoding: utf-8 -*-


require 'json'


module Sbr

  class Subcommand

    def parse(argv)
      @parser.parse! argv
    end

    def help
      @parser.help
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
        post_data["add_tags"] = true if opts["add_tags"] || @options[:add_tags]
        post_url = @options[:repository] + "api/post"
        res = @hc.post(post_url, post_data)
        result = JSON.parse(res.body)
        if result["status"] == "Accepted"
          photo = result["photo"]
          puts "  => Accepted: id=#{photo['id']} size=#{photo['width']}x#{photo['height']}"
          @counter[:accepted] += 1
        elsif result["status"] == "Add tags"
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
    end

    def clip_photo(photourl, opts = {})
      puts photourl
      post_data = {
        "url"      => photourl,
        "page_url" => opts["page_url"],
        "tags"     => opts["tags"],
        "force"    => opts["force"]
      }
      post_url = @options[:repository] + "api/clip"
      res = @hc.post(post_url, post_data)
      result = JSON.parse(res.body)
      if result["status"] == "Accepted"
        photo = result["photo"]
        puts "  => Accepted: id=#{photo['id']} size=#{photo['width']}x#{photo['height']}"
        @counter[:accepted] += 1
      elsif result["status"] == "Add tags"
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
