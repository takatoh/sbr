# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'httpclient'
require 'json'
require 'optparse'


module Sbr

  class GetPostCommand < Subcommand

    def initialize
      super
      @options = {
        :repository => @config["repository"],
        :limit      => nil,
        :offset     => nil
      }
      @parser = OptionParser.new
      @parser.banner =<<EOB
  #{@parser.program_name} get-post - Get post(s).
  Usage: #{@parser.program_name} get-post [options] [id]
EOB
      @parser.on('-R', '--repository=URL', 'Set repository url.'){|v| @options[:repository] = v}
      @parser.on('-l', '--limit=N', 'Set limit to get.'){|v| @options[:limit] = v}
      @parser.on('-o', '--offset=O', 'Set offset to get.'){|v| @options[:offset] = v}
    end

    def exec(argv)
      @hc = HTTPClient.new
      unless argv.empty?
        api_url = @options[:repository] + "api/post/" + argv.first
      else
        api_url = @options[:repository] + "api/posts"
        query = [:limit, :offset].map do |o|
          @options[o] ? "#{o.to_s}=#{@options[o]}" : nil
        end.compact.join("&")
        api_url += "?#{query}" unless query.empty?
      end
      json = @hc.get(api_url).body
      posts = JSON.parse(json)
      posts.each do |post|
        puts "Id:        #{post['id']}"
        puts "Source:    #{post['source']}"
        puts "Web page:  #{post['webPage']}"
        puts "Title:     #{post['title']}"
        puts "Photo Id:  #{post['photoId']}"
        puts ""
      end
    end

  end

end
