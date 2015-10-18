#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'sbr/scraper'


url = ARGV.shift

scraper = Sbr::Scraper.new(url, {})
scraper.scrape

puts "Linked images:"
scraper.linked_images.each{|img| puts img}
puts "Embeded images:"
scraper.embeded_images.each{|img| puts img}
