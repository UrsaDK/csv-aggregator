# frozen_string_literal: true

describe Combine::Datasources::Csv do
  let(:row_object) { instance_double('CSV::Row') }
  let(:row_hash) { { 'H1' => 'V1', 'H2' => 'V2' } }
  let(:formatter) { double(H1: 'F1') } # rubocop: disable RSpec/VerifiedDoubles
  let(:csv_object) { instance_double('CSV') }

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:readable?).and_return(true)
    allow(row_object).to receive(:to_h).and_return(row_hash)
    allow(Combine::Config).to receive(:[]).with(:csv).and_return({})
    allow(CSV).to receive(:foreach).and_yield(row_object)
    allow(csv_object).to receive(:<<)
    allow(CSV).to receive(:generate).and_yield(csv_object)
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
    subject(:str_out) { described_class.new('').tap { |k| k.data = [row_hash] }.to_s }

    it do
      str_out
      expect(csv_object).to have_received(:<<).with(%w[H1 H2])
    end

    it do
      str_out
      expect(csv_object).to have_received(:<<).with(%w[V1 V2])
    end
  end
end
