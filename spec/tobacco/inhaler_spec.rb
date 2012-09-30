require 'spec_helper'
require 'tobacco'

describe Tobacco::Inhaler do

  subject { Tobacco::Inhaler.new(url) }

  describe '#new' do
    let!(:url) { 'http://google.com/videos' }

    it 'sets the url' do
      subject.url.should == url
    end
  end

  describe '#read' do

    context 'when reading a url succeeds' do
      let!(:url) { 'http://www.iana.org/domains/example/' }

      before { VCR.insert_cassette('url_content') }
      after { VCR.eject_cassette() }

      it 'reads content from a url' do
        subject.read
      end
    end

    context 'when reading a url fails' do
      let!(:url) { 'http://somehost' }

      it 'errors on reading' do
        expect { subject.read }.to raise_error(Tobacco::Burnout::MaximumAttemptsExceeded)
      end
    end
  end

end
