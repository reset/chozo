require 'chozo/platform'

module Kernel
  include Chozo::Platform
end

class Object
  # Re-include since we updated the Kernel module
  include Kernel
end
