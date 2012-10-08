require 'spec_helper'

describe Hash do
  describe "ClassMethods" do
    subject { Hash }

    describe "::from_dotted_path" do
      it "returns a new Hash" do
        subject.from_dotted_path("deep.nested.item").should be_a(Hash)
      end

      it "a hash containing the nested keys" do
        obj = subject.from_dotted_path("deep.nested.item")

        obj.should have_key("deep")
        obj["deep"].should have_key("nested")
        obj["deep"]["nested"].should have_key("item")
      end

      it "sets a nil value for the deepest nested item" do
        obj = subject.from_dotted_path("deep.nested.item")

        obj["deep"]["nested"]["item"].should be_nil
      end

      context "when given a seed value" do
        it "sets the value of the deepest nested item to the seed" do
          obj = subject.from_dotted_path("deep.nested.item", "seeded_value")

          obj["deep"]["nested"]["item"].should eql("seeded_value")
        end
      end
    end
  end

  subject { Hash.new }

  describe "#dig" do
    context "when the Hash contains the nested path" do
      subject do
        {
          "we" => {
            "found" => {
              "something" => true
            }
          }
        }
      end

      it "returns the value at the dotted path" do
        subject.dig("we.found.something").should be_true
      end
    end

    context "when the Hash does not contain the nested path" do
      it "returns a nil value" do
        subject.dig("nothing.is.here").should be_nil
      end
    end
  end
end
