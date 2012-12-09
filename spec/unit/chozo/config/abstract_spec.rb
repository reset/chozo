require 'spec_helper'

describe Chozo::Config::Abstract do
  subject { Class.new(described_class).new }

  describe "#to_hash" do
    it "returns a Hash" do
      subject.to_hash.should be_a(Hash)
    end

    it "contains all of the attributes" do
      subject.attributes[:something] = "value"
      
      subject.to_hash.should have_key(:something)
      subject.to_hash[:something].should eql("value")
    end
  end
end
