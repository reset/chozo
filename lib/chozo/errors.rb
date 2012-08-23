module Chozo
  module Errors
    class ChozoError < StandardError; end
    class ConfigNotFound < ChozoError; end
    class InvalidConfig < ChozoError; end
  end
end
