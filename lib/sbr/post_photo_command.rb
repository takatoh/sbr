# -*- encoding: utf-8 -*-


require 'httpclient'
require 'optparse'


module Sbr

  class PostPhotoCommand < Subcommand

    def initialize
      @options = {
        :source   => "",
        :page_url => "",
        :tags     => ""
      }
      @parser = OptionParser.new
      @parser.banner =<<EOB
  #{@parser.program_name} post - Post photo(s).
  Usage: #{@parser.program_name} post [options] <photofile>
EOB
      @parser.on('-s', '--source=SOURCE', 'Set source of photo.'){|v| @options[:source] = v}
      @parser.on('-p', '--page_url=URL', 'Set webpage url.'){|v| @options[:page_url] = v}
      @parser.on('-t', '--tags=TAGS', 'Set tags.'){|v| @options[:tags] = v}
    end

    def exec(argv)
      photofile = argv.shift
      hc = HTTPClient.new
      post_data = {
        "url" => @options[:source],
        "page_url" => @options[:page_url],
        "tags"     => @options[:tags],
        "file"     => File.open(photofile, "br")
      }
      hc.post(post_data)
    end

  end

end
