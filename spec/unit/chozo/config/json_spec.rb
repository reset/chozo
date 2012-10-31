require 'spec_helper'

describe Chozo::Config::JSON do
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
    subject do
      Class.new(Chozo::Config::JSON) do
        attribute :name, required: true
        attribute :job
      end
    end

    describe "::from_json" do
      it "returns an instance of the inheriting class" do
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
        File.open(file, "w") { |f| f.write(json) }
      end

      it "returns an instance of the inheriting class" do
        subject.from_file(file).should be_a(subject)
      end

      it "sets the object's filepath to the path of the loaded file" do
        subject.from_file(file).path.should eql(file)
      end

      context "given a file that does not exist" do
        it "raises a Chozo::Errors::ConfigNotFound error" do
          lambda {
            subject.from_file(tmp_path.join("asdf.txt"))
          }.should raise_error(Chozo::Errors::ConfigNotFound)
        end
      end
    end
  end

  subject do
    Class.new(Chozo::Config::JSON) do
      attribute :name, required: true
      attribute :job
    end.new
  end

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
      subject.from_json(json).should be_a(Chozo::Config::JSON)
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
