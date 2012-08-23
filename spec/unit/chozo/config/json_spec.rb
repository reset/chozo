require 'spec_helper'
require 'shared_examples/chozo/config'

TestJSONConfig = Class.new do
  include Chozo::Config::JSON

  attribute :name
  validates_presence_of :name

  attribute :job
end

describe Chozo::Config::JSON do
  it_behaves_like "Chozo::Config", TestJSONConfig

  let(:json) do
    %(
      {
        "name": "reset",
        "job": "programmer",
        "status": "awesome"
      }
    )
  end

  describe "ClassMethods" do
    subject { TestJSONConfig }

    describe "::from_json" do
      it "returns an instance of the including class" do
        subject.from_json(json).should be_a(subject)
      end

      it "assigns values for each defined attribute" do
        config = subject.from_json(json)

        config[:name].should eql("reset")
        config[:job].should eql("programmer")
      end

      it "does not set an attribute value for undefined attributes" do
        config = subject.from_json(json)

        config[:status].should be_nil
      end
    end

    describe "::from_file" do
      let(:file) { tmp_path.join("test_config.json").to_s }

      before(:each) do
        File.write(file, json)
      end

      it "returns an instance of MB::Config" do
        subject.from_file(file).should be_a(TestJSONConfig)
      end

      it "sets the object's filepath to the path of the loaded file" do
        subject.from_file(file).path.should eql(file)
      end

      context "given a file that does not exist" do
        it "raises a MB::ConfigNotFound error" do
          lambda {
            subject.from_file(tmp_path.join("asdf.txt"))
          }.should raise_error(Chozo::Errors::ConfigNotFound)
        end
      end
    end
  end

  subject { TestJSONConfig.new }

  describe "#to_json" do
    before(:each) do
      subject.name = "reset"
      subject.job = "programmer"
    end

    it "returns JSON with key values for each attribute" do
      hash = parse_json(subject.to_json)

      hash.should have_key("name")
      hash["name"].should eql("reset")
      hash.should have_key("job")
      hash["job"].should eql("programmer")
    end
  end

  describe "#from_json" do
    it "returns an instance of the updated class" do
      subject.from_json(json).should be_a(subject.class)
    end

    it "assigns values for each defined attribute" do
      config = subject.from_json(json)

      config[:name].should eql("reset")
      config[:job].should eql("programmer")
    end

    it "does not set an attribute value for undefined attributes" do
      config = subject.from_json(json)

      config[:status].should be_nil
    end
  end
end
