# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'http'
require 'json'
require 'optparse'


module Sbr

  class GetPhotoCommand < Subcommand

    def initialize
      super
      @options = {
        :repository => @config["repository"],
        :limit      => nil,
        :offset     => nil,
        :json       => false,
        :md5        => false
      }
      @parser = OptionParser.new
      @parser.banner =<<EOB
  #{@parser.program_name} get-photo - Get photo(s).
  Usage: #{@parser.program_name} get-photo [options] [id]
         #{@parser.program_name} get-photo --md5 md5
EOB
      @parser.on('-R', '--repository=URL', 'Set repository url.'){|v| @options[:repository] = v}
      @parser.on('-l', '--limit=N', 'Set limit to get.'){|v| @options[:limit] = v}
      @parser.on('-o', '--offset=O', 'Set offset to get.'){|v| @options[:offset] = v}
      @parser.on('-m', '--md5', 'Get by md5.'){|v| @options[:md5] = true}
      @parser.on('-j', '--json-dump', 'Dump JSON.'){|v| @options[:json] = true}
    end

    def exec(argv)
      #@hc = HTTPClient.new
      if @options[:md5]
        unless argv.empty?
          api_url = @options[:repository] + "api/photo/md5/" + argv.shift
        else
          $stderr.puts "Error: Pleas specify MD5."
          exit(1)
        end
      else
        unless argv.empty?
          api_url = @options[:repository] + "api/photo/" + argv.first
        else
          api_url = @options[:repository] + "api/photos"
          query = [:limit, :offset].map do |o|
            @options[o] ? "#{o.to_s}=#{@options[o]}" : nil
          end.compact.join("&")
          api_url += "?#{query}" unless query.empty?
        end
      end
      #json = @hc.get(api_url).body
      #photos = JSON.parse(json)
      response = HTTP.get(api_url)
      photos = JSON.parse(response.to_s)
      if @options[:json]
        puts JSON.pretty_generate(photos)
      else
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

end
