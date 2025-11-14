# frozen_string_literal: true

require 'spec_helper'
require 'translation_service'

RSpec.describe TranslationService do
  describe '.translate' do
    let(:text) { 'Ciao mamma!' }

    context 'with translation' do
      let(:translated_text) { 'Mamma mia!' }

      before do
        stub_request(:post, 'https://api.funtranslations.com/translate/dario.json')
          .with(body: { text: text })
          .to_return(
            status: 200,
            body: {
              success: { total: 1 },
              contents: {
                translated: translated_text,
                text: text,
                translation: 'dario'
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns translated text' do
        result = TranslationService.translate(text, :dario)

        expect(result).to eq(translated_text)
      end
    end

    context 'when translation fails' do
      before do
        stub_request(:post, 'https://api.funtranslations.com/translate/shakespeare.json')
          .with(body: { text: text })
          .to_return(status: 429)
      end

      it 'returns original text' do
        result = TranslationService.translate(text, :shakespeare)

        expect(result).to eq(text)
      end
    end

    context 'when API returns error' do
      before do
        stub_request(:post, 'https://api.funtranslations.com/translate/yoda.json')
          .with(body: { text: text })
          .to_return(status: 500)
      end

      it 'returns original text' do
        result = TranslationService.translate(text, :yoda)

        expect(result).to eq(text)
      end
    end

    context 'when network error occurs' do
      before do
        stub_request(:post, 'https://api.funtranslations.com/translate/shakespeare.json')
          .to_raise(StandardError.new('Network error'))
      end

      it 'returns original text' do
        result = TranslationService.translate(text, :shakespeare)

        expect(result).to eq(text)
      end
    end
  end
end
