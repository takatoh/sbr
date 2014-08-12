require "sbr/version"

module Sbr

  class Subcommand
    def parse(argv)
      @parser.parse! argv
    end

    def help
      @parser.help
    end
  end

end
