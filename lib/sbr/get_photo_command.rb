# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'httpclient'
require 'json'
require 'optparse'


module Sbr

  class GetPhotoCommand < Subcommand

    def initialize
      super
      @options = {
        :repository => @config["repository"],
        :limit      => nil,
        :offset     => nil
      }
      @parser = OptionParser.new
      @parser.banner =<<EOB
  #{@parser.program_name} get-photo - Get photo(s).
  Usage: #{@parser.program_name} get-photo [options] [id]
EOB
      @parser.on('-R', '--repository=URL', 'Set repository url.'){|v| @options[:repository] = v}
      @parser.on('-l', '--limit=N', 'Set limit to get.'){|v| @options[:limit] = v}
      @parser.on('-o', '--offset=O', 'Set offset to get.'){|v| @options[:offset] = v}
    end

    def exec(argv)
      @hc = HTTPClient.new
      photos = unless argv.empty?
        api_url = @options[:repository] + "api/photo/" + argv.first
        json = @hc.get(api_url).body
        JSON.parse(json)
      else
        api_url = @options[:repository] + "api/photos"
        query = [:limit, :offset].map do |o|
          @options[o] ? "#{o.to_s}=#{@options[o]}" : nil
        end.compact.join("&")
        api_url += "?#{query}" unless query.empty?
        json = @hc.get(api_url).body
        JSON.parse(json)
      end
      photos.each do |photo|
        puts "Id:        #{photo['id']}"
        puts "File name: #{photo['fileName']}"
        puts "File size: #{photo['fileSize']}"
        puts "MD5:       #{photo['md5']}"
        puts "Size:      #{photo['width']}x#{photo['height']}"
        puts "File URL:  #{photo['fileUrl']}"
        puts ""
      end
    end

  end

end
