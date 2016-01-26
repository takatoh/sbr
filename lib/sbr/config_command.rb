# -*- encoding: utf-8 -*-


require 'sbr/subcommand'
require 'optparse'


module Sbr

  class ConfigCommand < Subcommand

    def initialize
      super
      @parser = OptionParser.new
      @parser.banner =<<EOB
  #{@parser.program_name} config - Set or get config.
  Usage: #{@parser.program_name} config <key> [value]
EOB
    end

    def exec(argv)
      if argv.size == 1
        puts @config[argv[0]]
      elsif argv.size == 2
        @config[argv[0]] = argv[1]
        File.open(@config_file, "w") do |f|
          f.print @config.to_yaml
        end
      end
    end

  end   # of class ConfigCommand

end   # of module Sbr
