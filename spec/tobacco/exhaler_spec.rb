require 'spec_helper'
require 'tobacco'

describe Tobacco::Exhaler do

  subject { Tobacco::Exhaler }

  let(:exhaler) { subject.new(content, filepath) }

  describe '#new' do
    context 'when passing arguments' do
      let(:content) { 'File content' }
      let(:filepath) { '/users/someuser/work/index.html' }

      it 'sets the content' do
        exhaler.filepath.should == filepath
      end

      it 'sets the filepath' do
        exhaler.content.should == content
      end
    end

    context 'when setting attributes after creation' do
      let(:exhaler) { Tobacco::Exhaler.new }

      it 'sets the content' do
        exhaler.content = 'new content'

        exhaler.content.should == 'new content'
      end

      it 'sets the filepath' do
        exhaler.filepath = '/var/other'

        exhaler.filepath.should == '/var/other'
      end
    end
  end

  describe 'file operations' do
    let(:filepath) { '/tmp/base_dir/index.html' }
    let(:dir)      { '/tmp/base_dir/' }
    let(:content) { '<h1>Page Title</h1>' }

    before do
      FileUtils.mkdir_p(dir)
      File.open(filepath, 'w') { |f| f.write content }
    end

    after { FileUtils.rm_rf(dir) }

    describe '#create_directory' do
      it 'creates a directory based on a filepath' do
        exhaler.create_directory

        File.exists?(dir).should be_true
      end
    end

    describe '#write!' do
      it 'writes content to a file' do
        exhaler.write!
        File.read(filepath).should == content
      end
    end
  end
end
