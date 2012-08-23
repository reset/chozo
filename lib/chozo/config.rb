require 'active_model'
require 'chozo/errors'

module Chozo
  module Config
    autoload :JSON, 'chozo/config/json'

    extend ActiveSupport::Concern

    included do
      include ActiveModel::AttributeMethods
      include ActiveModel::Validations
      attribute_method_suffix('=')
    end

    module ClassMethods
      # @return [Set]
      def attributes
        @attributes ||= Set.new
      end

      # @return [Hash]
      def defaults
        @defaults ||= Hash.new
      end

      # @param [Symbol] name
      # @param [Hash] options
      #
      # @return [Hash]
      def attribute(name, options = {})
        if options[:default]
          default_for_attribute(name, options[:default])
        end
        define_attribute_method(name)
        attributes << name.to_sym
      end

      private

        def default_for_attribute(name, value)
          defaults[name.to_sym] = value
        end
    end

    attr_accessor :path

    # @param [String] path
    # @param [Hash] attributes
    def initialize(path = nil, attributes = {})
      @path = File.expand_path(path) if path
      self.attributes = attributes
    end

    # @param [Symbol] key
    #
    # @return [Object]
    def attribute(key)
      instance_variable_get("@#{key}") || self.class.defaults[key]
    end
    alias_method :[], :attribute

    # @param [Symbol] key
    # @param [Object] value
    def attribute=(key, value)
      instance_variable_set("@#{key}", value)
    end
    alias_method :[]=, :attribute=

    # @param [Hash] new_attributes
    def attributes=(new_attributes)
      new_attributes.symbolize_keys!

      self.class.attributes.each do |attr_name|
        send(:attribute=, attr_name, new_attributes[attr_name.to_sym])
      end
    end

    # @param [Symbol] key
    #
    # @return [Boolean]
    def attribute?(key)
      instance_variable_get("@#{key}").present?
    end

    # @return [Hash]
    def attributes
      {}.tap do |attrs|
        self.class.attributes.each do |attr|
          attrs[attr] = attribute(attr)
        end
      end
    end

    # @return [String]
    def to_s
      "[#{self.class}] '#{self.path}': #{self.attributes}"
    end
  end
end
