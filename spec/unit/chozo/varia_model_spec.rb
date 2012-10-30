require 'spec_helper'

describe Chozo::VariaModel do
  describe "ClassMethods" do
    subject do
      Class.new do
        include Chozo::VariaModel
      end
    end    

    describe "::attributes" do
      it "returns a Hashie::Mash" do
        subject.attributes.should be_a(Hashie::Mash)
      end

      it "is empty by default" do
        subject.attributes.should be_empty
      end
    end

    describe "::attribute" do
      it "adds an attribute to the attributes hash for each attribute function call" do
        subject.attribute 'jamie.winsor'
        subject.attribute 'brooke.winsor'

        subject.attributes.should have(2).items
      end

      it "adds a validation if :required option is true" do
        subject.attribute 'brooke.winsor', required: true

        subject.validations.should have(1).item
      end

      it "adds a validation if the :type option is provided" do
        subject.attribute 'brooke.winsor', type: :string

        subject.validations.should have(1).item
      end

      it "sets a default value if :default option is provided" do
        subject.attribute 'brooke.winsor', default: 'rhode island'

        subject.attributes.dig('brooke.winsor').should eql('rhode island')
      end
    end

    describe "::validations" do
      it "returns a HashWithIndifferentAccess" do
        subject.validations.should be_a(HashWithIndifferentAccess)
      end

      it "is empty by default" do
        subject.validations.should be_empty
      end
    end
  end

  subject do
    Class.new do
      include Chozo::VariaModel

      attribute 'nested.not_coerced', default: 'hello'
      attribute 'nested.no_default'
      attribute 'nested.coerced', coerce: lambda { |m| m.to_s }
      attribute 'toplevel', default: 'hello'
      attribute 'no_default'
      attribute 'coerced', coerce: lambda { |m| m.to_s }
    end.new
  end

  describe "GeneratedAccessors" do
    describe "nested getter" do
      it "returns the default value" do
        subject.nested.not_coerced.should eql('hello')
      end

      it "returns nil if there is no default value" do
        subject.nested.no_default.should be_nil
      end
    end

    describe "toplevel getter" do
      it "returns the default value" do
        subject.toplevel.should eql('hello')
      end

      it "returns nil if there is no default value" do
        subject.no_default.should be_nil
      end
    end

    describe "nested setter" do
      it "sets the value of the nested attribute" do
        subject.nested.not_coerced = 'world'

        subject.nested.not_coerced.should eql('world')
      end
    end

    describe "toplevel setter" do
      it "sets the value of the top level attribute" do
        subject.toplevel = 'world'

        subject.toplevel.should eql('world')
      end
    end

    describe "nested coerced setter" do
      it "sets the value of the nested coerced attribute" do
        subject.nested.coerced = 1

        subject.nested.coerced.should eql("1")
      end
    end

    describe "toplevel coerced setter" do
      it "sets the value of the top level coerced attribute" do
        subject.coerced = 1

        subject.coerced.should eql('1')
      end
    end
  end

  describe "Validations" do
    describe "validate required" do
      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'brooke.winsor', required: true
        end.new
      end

      it "is not valid if it fails validation" do
        subject.should_not be_valid
      end

      it "adds an error for each attribute that fails validations" do
        subject.validate

        subject.errors.should have(1).item
      end

      it "adds a message for each failed validation" do
        subject.validate

        subject.errors['brooke.winsor'].should have(1).item
        subject.errors['brooke.winsor'][0].should eql("A value is required for attribute: 'brooke.winsor'")
      end
    end

    describe "validate type" do
      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'brooke.winsor', type: String
        end.new
      end

      it "returns false if it fails validation" do
        subject.should_not be_valid
      end

      it "adds an error if it fails validation" do
        subject.validate

        subject.errors.should have(1).item
        subject.errors['brooke.winsor'].should have(1).item
        subject.errors['brooke.winsor'][0].should eql("Expected attribute: 'brooke.winsor' to be a type of: 'String'")
      end
    end
  end
end
