# frozen_string_literal: true

require 'httparty'

class TranslationService
  BASE_URL = 'https://api.funtranslations.com/translate'

  def self.translate(text, type)
    response = HTTParty.post(
      "#{BASE_URL}/#{type}.json",
      body: { text: text }
    )

    return text unless response.success?

    response.parsed_response.dig('contents', 'translated') || text
  rescue StandardError
    text
  end
end
