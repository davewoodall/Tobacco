require 'spec_helper'

describe Tobacco::SafetyNet do
  let(:safety_net) { Tobacco::SafetyNet }
  let(:filepath)   { '/tmp/tempfile.txt' }
  let(:content)    { 'This little piggy went to market...' }

  before do
    File.open(filepath, 'w') {|f| f.write content }
    @safety_net = safety_net.new(filepath)
    @safety_net.backup
  end

  context 'when backing up' do
    after { @safety_net.destroy }

    it 'creates a tempfile' do
      File.exists?(@safety_net.destination).should be_true
    end

    it 'has correct content' do
      File.read(@safety_net.destination).should == content
    end
  end

  context 'when restoring the original file' do
    before { @safety_net.restore }

    it 'works' do
      File.exists?(filepath).should be_true
    end

    it 'has the correct content' do
      File.read(filepath).should == content
    end
  end
end
