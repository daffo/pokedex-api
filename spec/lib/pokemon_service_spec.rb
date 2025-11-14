# frozen_string_literal: true

require 'spec_helper'
require 'pokemon_service'

RSpec.describe PokemonService do
  describe '.fetch_pokemon' do
    let(:pokemon_name) { 'mewtwo' }

    context 'when the pokemon exists' do
      let(:api_response) do
        {
          name: 'mewtwo',
          is_legendary: true,
          habitat: {
            name: 'rare',
            url: 'https://pokeapi.co/api/v2/pokemon-habitat/5/'
          },
          flavor_text_entries: [
            {
              flavor_text: "It was created by\na scientist after\nyears of horrific\fgene splicing and\nDNA engineering\nexperiments.",
              language: { name: 'en', url: 'https://pokeapi.co/api/v2/language/9/' }
            }
          ]
        }
      end

      before do
        stub_request(:get, "https://pokeapi.co/api/v2/pokemon-species/#{pokemon_name}")
          .to_return(
            status: 200,
            body: api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns pokemon information with cleaned description' do
        result = PokemonService.fetch_pokemon(pokemon_name)

        expect(result[:name]).to eq('mewtwo')
        expect(result[:isLegendary]).to be true
        expect(result[:habitat]).to eq('rare')
        expect(result[:description]).to eq('It was created by a scientist after years of horrific gene splicing and DNA engineering experiments.')
      end
    end

    context 'when the pokemon does not exist' do
      before do
        stub_request(:get, 'https://pokeapi.co/api/v2/pokemon-species/unknown')
          .to_return(status: 404)
      end

      it 'returns nil' do
        result = PokemonService.fetch_pokemon('unknown')

        expect(result).to be_nil
      end
    end

    context 'when habitat is missing' do
      let(:api_response) do
        {
          name: 'ditto',
          is_legendary: false,
          habitat: nil,
          flavor_text_entries: [
            {
              flavor_text: 'It can freely recombine its own cellular structure.',
              language: { name: 'en', url: 'https://pokeapi.co/api/v2/language/9/' }
            }
          ]
        }
      end

      before do
        stub_request(:get, 'https://pokeapi.co/api/v2/pokemon-species/ditto')
          .to_return(
            status: 200,
            body: api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns nil for habitat' do
        result = PokemonService.fetch_pokemon('ditto')

        expect(result[:habitat]).to be_nil
      end
    end
  end
end
