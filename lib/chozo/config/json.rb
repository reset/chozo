require 'multi_json'

module Chozo
  module Config
    module JSON
      extend ActiveSupport::Concern
      include Chozo::Config

      module ClassMethods
        # @param [String] data
        #
        # @return [~Chozo::Config::JSON]
        def from_json(data)
          new.from_json(data)
        end

        # @param [String] path
        #
        # @raise [Chozo::Errors::ConfigNotFound]
        #
        # @return [~Chozo::Config::JSON]
        def from_file(path)
          data = File.read(path)
          new(path).from_json(data)
        rescue Errno::ENOENT, Errno::EISDIR
          raise Chozo::Errors::ConfigNotFound, "No configuration found at: '#{path}'"
        end
      end

      # @param (see MultiJson.encode) options
      #
      # @return [String]
      def to_json(options = {})
        MultiJson.encode(self.attributes, options)
      end
      alias_method :as_json, :to_json

      # @param (see MultiJson.decode) json
      # @param (see MultiJson.decode) options
      #
      # @raise [Chozo::Errors::InvalidConfig]
      #
      # @return [~Chozo::Config::JSON]
      def from_json(json, options = {})
        self.attributes = MultiJson.decode(json, options)
        self
      rescue MultiJson::DecodeError => e
        raise Chozo::Errors::InvalidConfig, e
      end

      def save(destination = self.path)
        FileUtils.mkdir_p(File.dirname(destination))
        File.open(destination, 'w+') do |f|
          f.puts self.to_json
        end
      end
    end
  end
end
