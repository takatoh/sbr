require "sbr/version"
require "sbr/post_photo_command"


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
