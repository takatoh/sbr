# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'httpclient'
require 'json'
require 'optparse'


module Sbr

  class StatisticsCommand < Subcommand

    def initialize
      super
      @options = {
        :repository => @config["repository"]
      }
      @parser = OptionParser.new
      @parser.banner =<<EOB
  #{@parser.program_name} statistics - Get statistics information.
  Usage: #{@parser.program_name} statistics [options]
EOB
      @parser.on('-R', '--repository=URL', 'Set repository url.'){|v| @options[:repository] = v}
    end

    def exec(argv)
      @hc = HTTPClient.new
      api_url = @options[:repository] + "api/statistics"
      json = @hc.get(api_url).body
      statistics = JSON.parse(json)['statistics']
      puts "Photos:  #{statistics['photos']}"
      puts "Posts:   #{statistics['posts']}"
      puts ""
    end

  end

end
