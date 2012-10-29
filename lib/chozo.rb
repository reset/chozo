# @author Jamie Winsor <jamie@vialstudios.com>
module Chozo
  autoload :Config, 'chozo/config'
  autoload :Errors, 'chozo/errors'
  autoload :Platform, 'chozo/platform'
  autoload :RubyEngine, 'chozo/ruby_engine'
end

require 'chozo/core_ext'
require 'active_support/core_ext'
