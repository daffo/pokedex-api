# frozen_string_literal: true

require 'httparty'
require 'json'

class TranslationService
  BASE_URL = 'https://api.funtranslations.com/translate'

  def self.translate(text, type)
    response = HTTParty.post(
      "#{BASE_URL}/#{type}.json",
      body: { text: text }
    )

    return text unless response.success?

    data = response.parsed_response
    data = JSON.parse(data) if data.is_a?(String)

    data.dig('contents', 'translated') || text
  rescue StandardError
    text
  end
end
