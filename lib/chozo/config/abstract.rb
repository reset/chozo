require 'forwardable'
require 'chozo/varia_model'

module Chozo
  module Config
    # @author Jamie Winsor <jamie@vialstudios.com>
    # @api private
    class Abstract
      include VariaModel
      
      attr_accessor :path

      # @param [String] path
      # @param [Hash] attributes
      def initialize(path = nil, attributes = {})
        @path = File.expand_path(path) if path

        mass_assign(attributes)
      end

      def [](key)
        self.attributes[key]
      end

      def []=(key, value)
        self.attributes[key] = value
      end

      protected

        def mass_assign(attributes = {})
          attributes.each do |key, value|
            if respond_to?("#{key}=")
              self.send("#{key}=", value)
            end
          end
        end
    end
  end
end
