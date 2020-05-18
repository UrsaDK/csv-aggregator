# frozen_string_literal: true

describe Combine::Config do
  let(:config) do
    {
      string: 'test',
      array: %w[one two],
      hash: { one: 1, two: 2 },
      array_of_hashes: [{ a: 1, b: 2 }, { c: 1, d: 2 }]
    }
  end

  before do
    allow(YAML).to receive(:load_file) { config }
    allow(YAML).to receive(:load_file).with('second_config').and_return(integer: 1)
  end

  describe 'class respond to' do
    subject { described_class }
    it { is_expected.to respond_to :[] }
    it { is_expected.to respond_to :[]= }
    it { is_expected.to respond_to :load }
    it { is_expected.to have_attributes(config: nil) }
  end

  describe '::load' do
    context 'with a single config' do
      subject { described_class.load }
      it { is_expected.to eq(config) }
    end

    context 'with two configs' do
      subject { described_class.load('second_config') }
      it { is_expected.to eq(config.merge(integer: 1)) }
    end
  end

  describe '::[]' do
    subject(:fetch) do
      described_class.load
      described_class.send(:[], :string)
    end
    it { is_expected.to eq('test') }
  end

  describe '::[]=' do
    subject(:fetch) do
      described_class.load
      described_class.send(:[]=, :string, 'test2')
      described_class.send(:[], :string)
    end
    it { is_expected.to eq('test2') }
  end
end
