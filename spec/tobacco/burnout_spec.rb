require 'spec_helper'

describe Tobacco::Burnout do
  subject { Tobacco::Burnout }

  let(:call_count) { 0 }
  let(:max_timeouts) { 0 }

  let(:untimely_block) {
    ->(call_count, max_timeouts) {
      if call_count < max_timeouts
        call_count += 1

        raise Timeout::Error
      else
        return "an important value"
      end
    }
  }

  context "when the attempted block times out exactly X times" do
    before do
      max_timeouts = 5
    end

    it "raises nothing" do
      expect {
        subject.try(5) { untimely_block.call(call_count, max_timeouts) }
      }.to_not raise_error
    end

    it "returns whatever the block returned" do
      subject.try(5) { untimely_block.call(call_count, max_timeouts) }.should == "an important value"
    end
  end

  context "when the attempted block times out more than X times" do
    before do
      max_timeouts = 3
    end

    it "raises a MaximumAttemptsExceeded exception" do
      expect {
        subject.try(2) do
          untimely_block.call(0, 4)
        end
      }.to raise_error(Tobacco::Burnout::MaximumAttemptsExceeded, /more than 2 time/)
    end
  end
end

