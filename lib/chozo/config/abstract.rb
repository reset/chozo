require 'chozo/varia_model'

module Chozo
  module Config
    # @author Jamie Winsor <jamie@vialstudios.com>
    # @api private
    class Abstract
      extend Forwardable
      include VariaModel
      
      attr_accessor :path

      def_delegator :to_hash, :slice
      def_delegator :to_hash, :slice!
      def_delegator :to_hash, :extract!

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

      def to_hash
        self.attributes.to_hash.deep_symbolize_keys
      end

      protected

        def mass_assign(new_attributes = {})
          attributes.deep_merge!(new_attributes)
        end
    end
  end
end
