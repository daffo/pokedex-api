# frozen_string_literal: true

require 'httparty'
require 'json'

class PokemonService
  BASE_URL = 'https://pokeapi.co/api/v2'

  def self.fetch_pokemon(name)
    response = HTTParty.get("#{BASE_URL}/pokemon-species/#{name.downcase}")

    return nil unless response.success?

    data = response.parsed_response
    data = JSON.parse(data) if data.is_a?(String)

    {
      name: data['name'],
      description: extract_description(data['flavor_text_entries']),
      habitat: data['habitat']&.dig('name'),
      isLegendary: data['is_legendary']
    }
  end

  def self.extract_description(flavor_text_entries)
    return nil if flavor_text_entries.nil? || flavor_text_entries.empty?

    english_entry = flavor_text_entries.find { |entry| entry['language']['name'] == 'en' }
    return nil unless english_entry

    english_entry['flavor_text']
      .gsub(/[\n\f\r]/, ' ')
      .gsub(/\s+/, ' ')
      .strip
  end

  private_class_method :extract_description
end
