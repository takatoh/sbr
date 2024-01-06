# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'sbr/scraper'
require 'http'
require 'optparse'


module Sbr

  class ScrapePageCommand < Subcommand

    def initialize
      super
      @options = {
        :repository => @config["repository"],
        :page_url   => "",
        :tags       => "",
        :add_tags   => false,
        :force      => false
      }
      @parser = OptionParser.new
      @parser.banner =<<EOB
  #{@parser.program_name} scrape - Scrape page.
  Usage: #{@parser.program_name} scrape [options] <pageurl>
EOB
      @parser.on('-R', '--repository=URL', 'Set repository url.'){|v| @options[:repository] = v}
      @parser.on('-t', '--tags=TAGS', 'Set tags.'){|v| @options[:tags] = v}
      @parser.on('-f', '--force', 'Force clip.'){|v| @options[:force] = true}
      @parser.on('-a', '--add-tags', 'Add tags to be rejected.'){|v| @options[:add_tags] = true}
      @counter = {accepted: 0, rejected: 0, added_tags: 0, error: 0}
    end

    def exec(argv)
      pageurl = argv.shift
      scraper = Sbr::Scraper.new(pageurl, @options)
      scraper.scrape
      scraper.linked_images.each do |img|
        photourl = img[:image_url]
        opts = {
          "page_url" => img[:page_url],
          "tags"     => @options[:tags],
          "add_tags" => @options[:add_tags],
          "force"    => @options[:force]
        }
        clip_photo(photourl, opts)
      end
      puts ""
      puts "Accepted:   #{@counter[:accepted]}"
      puts "Rejected:   #{@counter[:rejected]}"
      puts "Added tags: #{@counter[:added_tags]}"
      puts "Error:      #{@counter[:error]}"
      puts "Total:      #{@counter[:accepted] + @counter[:rejected] + @counter[:added_tags] + @counter[:error]}"
    end

  end   # of class ScrapePageCommand

end   # of module Sbr
