require 'spec_helper'
require 'shared_examples/chozo/config'

TestConfig = Class.new do
  include Chozo::Config

  attribute :name
  validates_presence_of :name

  attribute :job
end

describe Chozo::Config do
  it_behaves_like "Chozo::Config", TestConfig

  subject do
    TestConfig.new
  end

  describe "Validations" do
    it "is valid if all required attributes are specified" do
      subject.name = "reset"

      subject.should be_valid
    end

    it "is not valid if a required attribute is not specified" do
      subject.name = nil

      subject.should_not be_valid
    end
  end
end
