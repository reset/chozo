require 'chozo/core_ext'
require 'chozo/hashie_ext'

module Chozo
  # @author Jamie Winsor <jamie@vialstudios.com>
  module VariaModel
    module ClassMethods
      # @return [HashWithIndifferentAccess]
      def attributes
        @attributes ||= Hashie::Mash.new
      end

      # @return [HashWithIndifferentAccess]
      def validations
        @validations ||= HashWithIndifferentAccess.new
      end

      # @param [#to_s] name
      # @option options [Symbol, Array<Symbol>] :type
      # @option options [Boolean] :required
      # @option options [Object] :default
      # @option options [Proc] :coerce
      def attribute(name, options = {})
        register_attribute(name.to_s, options)

        define_mimic_methods(name.to_s, options)
      end

      # @param [String] name
      #
      # @return [Array]
      def validations_for(name)
        self.validations[name] ||= Array.new
      end

      # @param [Constant, Array<Constant>] types
      # @param [VariaModel] model
      # @param [String] key
      #
      # @return [Array]
      def validate_kind_of(types, model, key)
        errors  = Array.new
        types   = Array(types)
        matches = false

        types.each do |type|
          if model.attributes.dig(key).is_a?(type)
            matches = true
            break
          end
        end

        if matches
          [ :ok, "" ]
        else
          types_msg = types.collect { |type| "'#{type}'" }
          [ :error, "Expected attribute: '#{key}' to be a type of: #{types_msg.join(', ')}" ]
        end
      end

      # @param [VariaModel] model
      # @param [String] key
      #
      # @return [Array]
      def validate_required(model, key)
        if model.attributes.dig(key).present?
          [ :ok, "" ]
        else
          [ :error, "A value is required for attribute: '#{key}'" ]
        end
      end

      private

        def register_attribute(name, options = {})
          if options[:type]
            register_validation(name, lambda { |object, key| validate_kind_of(options[:type], object, key) })
          end

          if options[:required]
            register_validation(name, lambda { |object, key| validate_required(object, key) })
          end

          class_eval do
            new_attributes = Hashie::Mash.from_dotted_path(name, options[:default])
            self.attributes.merge!(new_attributes)
            
            if options[:coerce].is_a?(Proc)
              register_coercion(name, options[:coerce])
            end
          end
        end

        def register_validation(name, fun)
          self.validations[name] = (self.validations_for(name) << fun)
        end

        def register_coercion(name, fun)
          self.attributes.container(name).set_coercion(name.split('.').last, fun)
        end

        def define_mimic_methods(name, options = {})
          fun_name = name.split('.').first

          if options[:dsl_mimics]
            class_eval do
              define_method fun_name do |value|
                value = if options[:coerce].is_a?(Proc)
                  options[:coerce].call(value)
                else
                  value
                end

                self.attributes[fun_name] = value
              end
            end
          else
            class_eval do
              define_method fun_name do
                self.attributes[fun_name]
              end

              define_method "#{fun_name}=" do |value|
                value = if options[:coerce].is_a?(Proc)
                  options[:coerce].call(value)
                else
                  value
                end

                self.attributes[fun_name] = value
              end
            end
          end
        end
    end

    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    # @param [#to_hash] new_attributes
    def initialize(new_attributes = {})
      self.attributes.merge!(Hashie::Mash.new(new_attributes.to_hash))
    end

    # @return [HashWithIndifferentAccess]
    def attributes
      @attributes ||= self.class.attributes.dup
    end

    def attributes=(hash)
      @attributes = Hashie::Mash.new(hash.to_hash)
    end

    # @return [HashWithIndifferentAccess]
    def validate
      self.class.validations.each do |attr_path, validations|
        validations.each do |validation|
          status, messages = validation.call(self, attr_path)

          if status == :error
            if messages.is_a?(Array)
              messages.each do |message|
                self.add_error(attr_path, message)
              end
            else
              self.add_error(attr_path, messages)
            end
          end
        end
      end

      self.errors
    end

    # @return [Boolean]
    def valid?
      validate.empty?
    end

    # @return [HashWithIndifferentAccess]
    def errors
      @errors ||= HashWithIndifferentAccess.new
    end

    protected

      # @param [String] attribute
      # @param [String] message
      def add_error(attribute, message)
        self.errors[attribute] ||= Array.new
        self.errors[attribute] << message
      end    
  end
end
