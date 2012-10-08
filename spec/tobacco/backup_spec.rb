require 'spec_helper'

describe Tobacco::Backup do
  let(:backup) { Tobacco::Backup }

  before do
    @tempfile = backup.new('/path/to/filename.txt', 'File content')
  end

  after { @tempfile.close }

  it 'creates a tempfile' do
    File.exists?(@tempfile.file.path).should be_true
  end

  it 'has correct content' do
    File.read(@tempfile.file.path).should == 'File content'
  end
end
