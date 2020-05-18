# frozen_string_literal: true

describe Combine::Datasources::Json do
  let(:row_string) { '[ { "H1": "V1", "H2": "V2" } ]' }
  let(:row_hash) { { 'H1' => 'V1', 'H2' => 'V2' } }
  let(:formatter) { double(H1: 'F1') } # rubocop: disable RSpec/VerifiedDoubles

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:readable?).and_return(true)
    allow(File).to receive(:read).and_return(row_string)
    allow(row_hash).to receive(:to_json)
  end

  describe 'class respond to' do
    subject { described_class }
    it { is_expected.to respond_to :new }
  end

  describe 'instance respond to' do
    subject { described_class.new }
    it { is_expected.to respond_to :file= }
    it { is_expected.to respond_to :fetch }
    it { is_expected.to respond_to :to_s }
  end

  describe '#initialize' do
    context 'when initialised with required arguments only' do
      subject { described_class.new }
      it { is_expected.to have_attributes(file: nil) }
    end

    context 'when initialised with required and optional arguments' do
      subject { described_class.new('/path/to/file') }
      it { is_expected.to have_attributes(file: '/path/to/file') }
    end
  end

  describe '#file=' do
    context 'with existing file' do
      subject { described_class.new.tap { |k| k.file = '/path/to/file' } }
      it { is_expected.to have_attributes(file: '/path/to/file') }
    end

    context 'with non-existent file' do
      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:readable?).and_return(false)
      end

      it do
        subject = ->(s) { s.new.file = '/path/to/file' }
        expect { subject.call(described_class) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#fetch' do
    context 'without formatter' do
      subject { described_class.new('/path/to/file').fetch }
      it { is_expected.to eq([row_hash]) }
    end

    context 'with valid formatter' do
      subject { described_class.new('').tap { |k| k.formatter = formatter }.fetch }
      it { is_expected.to eq([row_hash.merge('H1' => 'F1')]) }
    end

    context 'with invalid formatter' do
      subject { described_class.new('').tap { |k| k.formatter = formatter }.fetch }

      before do
        allow(formatter).to receive(:H1).and_raise(StandardError)
      end

      it do
        subject = ->(s) { s.new('').tap { |k| k.formatter = formatter }.fetch }
        expect { subject.call(described_class) }.to raise_error(StandardError)
      end
    end
  end

  describe '#to_s' do
    subject(:output) { described_class.new('').tap { |k| k.data = row_hash }.to_s }
    it do
      output
      expect(row_hash).to have_received(:to_json)
    end
  end
end
