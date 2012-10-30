# @author Jamie Winsor <jamie@vialstudios.com>
module Chozo
  autoload :Config, 'chozo/config'
  autoload :Errors, 'chozo/errors'
  autoload :Platform, 'chozo/platform'
  autoload :RubyEngine, 'chozo/ruby_engine'
  autoload :VariaModel, 'chozo/varia_model'
end

require 'chozo/core_ext'
require 'chozo/hashie_ext'
require 'active_support/core_ext'
