# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'httpclient'
require 'optparse'


module Sbr

  class ClipPhotoCommand < Subcommand

    def initialize
      @options = {
        :repository => "",
        :url        => "",
        :page_url   => "",
        :tags       => "",
        :add_tags   => false,
        :force      => false
      }
      @parser = OptionParser.new
      @parser.banner =<<EOB
  #{@parser.program_name} clip - Clip photo.
  Usage: #{@parser.program_name} clip [options] <photourl>
EOB
      @parser.on('-R', '--repository=URL', 'Set repository url.'){|v| @options[:repository] = v}
      @parser.on('-p', '--page-url=URL', 'Set webpage url.'){|v| @options[:page_url] = v}
      @parser.on('-t', '--tags=TAGS', 'Set tags.'){|v| @options[:tags] = v}
      @parser.on('-f', '--force', 'Force clip.'){|v| @options[:force] = true}
      @parser.on('-a', '--add-tags', 'Add tags to be rejected.'){|v| @options[:add_tags] = true}
      @counter = {accepted: 0, rejected: 0, added_tags: 0, error: 0}
      @hc = HTTPClient.new
    end

    def exec(argv)
      photourl = argv.shift
      opts = {
       "page_url" => @options[:page_url],
       "tags"     => @options[:tags],
       "add_tags" => @options[:add_tags],
       "force"    => @options[:force]
      }
      clip_photo(photourl, opts)
      puts ""
      puts "Accepted:   #{@counter[:accepted]}"
      puts "Rejected:   #{@counter[:rejected]}"
      puts "Added tags: #{@counter[:added_tags]}"
      puts "Error:      #{@counter[:error]}"
      puts "Total:      #{@counter[:accepted] + @counter[:rejected] + @counter[:added_tags] + @counter[:error]}"
    end

  end

end
