# frozen_string_literal: true

describe Combine::Cli do
  let(:config) do
    {
      output_format: nil,
      stores: {
        articles: nil,
        authors: nil,
        journals: nil
      }
    }
  end
  let(:stores) { instance_double(Hash) }

  before do
    allow(Combine::Config).to receive(:load) { config }
    allow(Combine::Config).to receive(:merge) { config }
    allow(Combine::Config).to receive(:[]=)
    allow(stores).to receive(:[]=)
    allow(Combine::Config).to receive(:[]) { stores }
    allow(Combine).to receive(:journals_articles_authors)
  end

  describe 'class respond to' do
    subject { described_class }
    it { is_expected.to respond_to :start }
    it { is_expected.to have_attributes(args: nil) }
    it { is_expected.to have_attributes(options: nil) }
    it { is_expected.to have_attributes(parser: nil) }
  end

  describe '::start' do
    subject(:passthrough) { described_class.start([]) }

    it 'passes the call onto Combine' do
      passthrough
      expect(Combine).to have_received(:journals_articles_authors)
    end

    context 'with a valid format' do
      %w[json csv].each do |format|
        subject("#{format}_format") { described_class.start(['--format', format]) }
        it "(#{format})" do
          send("#{format}_format")
          expect(Combine::Config).to have_received(:[]=).with(:output_format, format)
        end
      end
    end

    context 'with store as option' do
      %w[articles authors journals].each do |store|
        file = "/path/to/#{store}.ext"
        subject("#{store}_store") { described_class.start(["--#{store}", file]) }
        it "(#{store})" do
          send("#{store}_store")
          expect(stores).to have_received(:[]=).with(store.to_sym, file)
        end
      end
    end

    context 'with store as argument' do
      %w[articles authors journals].each do |store|
        file = "/path/to/#{store}.ext"
        subject("#{store}_store") { described_class.start([file]) }
        it "(#{store})" do
          send("#{store}_store")
          expect(stores).to have_received(:[]=).with(store.to_sym, file)
        end
      end
    end
  end
end
