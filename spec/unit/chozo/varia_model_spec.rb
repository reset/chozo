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

    describe "::validations_for" do
      context "when an attribute is registered and has validations" do
        before(:each) do
          subject.attribute("nested.attribute", required: true, type: String)
        end

        it "returns an array of procs" do
          validations = subject.validations_for("nested.attribute")

          validations.should be_a(Array)
          validations.should each be_a(Proc)
        end
      end

      context "when an attribute is registered but has no validations" do
        before(:each) do
          subject.attribute("nested.attribute")
        end

        it "returns an empty array" do
          validations = subject.validations_for("nested.attribute")

          validations.should be_a(Array)
          validations.should be_empty
        end
      end

      context "when an attribute is not registered" do
        it "returns an empty array" do
          validations = subject.validations_for("not_existing.attribute")

          validations.should be_a(Array)
          validations.should be_empty
        end
      end
    end

    describe "::validate_kind_of" do
      let(:types) do
        [
          String,
          Boolean
        ]
      end

      let(:key) do
        'nested.one'
      end

      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'nested.one', types: [String, Boolean]
        end
      end

      let(:model) do
        subject.new
      end

      it "returns an array" do
        subject.validate_kind_of(types, model, key).should be_a(Array)
      end

      context "failure" do
        before(:each) do
          model.nested.one = nil
        end

        it "returns an array where the first element is ':error'" do
          subject.validate_kind_of(types, model, key).first.should eql(:error)
        end

        it "returns an array where the second element is an error message containing the attribute and types" do
          types.each do |type|
            subject.validate_kind_of(types, model, key)[1].should =~ /#{type}/
          end
          subject.validate_kind_of(types, model, key)[1].should =~ /#{key}/
        end
      end

      context "success" do
        before(:each) do
          model.nested.one = true
        end

        it "returns an array where the first element is ':ok'" do
          subject.validate_kind_of(types, model, key).first.should eql(:ok)
        end

        it "returns an array where the second element is a blank string" do
          subject.validate_kind_of(types, model, key)[1].should be_blank
        end
      end
    end

    describe "::validate_required" do
      let(:key) do
        'nested.one'
      end

      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'nested.one', required: true
        end
      end

      let(:model) do
        subject.new
      end

      it "returns an array" do
        subject.validate_required(model, key).should be_a(Array)
      end

      context "failure" do
        before(:each) do
          model.nested.one = nil
        end

        it "returns an array where the first element is ':error'" do
          subject.validate_required(model, key).first.should eql(:error)
        end

        it "returns an array where the second element is an error message containing the attribute name" do
          subject.validate_required(model, key)[1].should =~ /#{key}/
        end
      end

      context "success" do
        before(:each) do
          model.nested.one = "hello"
        end

        it "returns an array where the first element is ':ok'" do
          subject.validate_required(model, key).first.should eql(:ok)
        end

        it "returns an array where the second element is a blank string" do
          subject.validate_required(model, key)[1].should be_blank
        end
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

    context "given two nested attributes with a common parent and default values" do
      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'nested.one', default: 'val_one'
          attribute 'nested.two', default: 'val_two'
        end.new
      end

      it "sets a default value for each nested attribute" do
        subject.nested.one.should eql('val_one')
        subject.nested.two.should eql('val_two')
      end
    end

    context "given two nested attributes with a common parent and coercions" do
      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'nested.one', coerce: lambda { |m| m.to_s }
          attribute 'nested.two', coerce: lambda { |m| m.to_s }
        end.new
      end

      it "coerces each value if both have a coercion" do
        subject.nested.one = 1
        subject.nested.two = 2

        subject.nested.one.should eql("1")
        subject.nested.two.should eql("2")
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
