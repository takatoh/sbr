# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'http'
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
      api_url = @options[:repository] + "api/statistics"
      response = HTTP.get(api_url)
      statistics = JSON.parse(response.to_s)['statistics']
      puts "Photos:  #{statistics['photos']}"
      puts "Posts:   #{statistics['posts']}"
      puts ""
    end

  end

end
