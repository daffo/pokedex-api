# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../app'

RSpec.describe 'Pokedex API' do
  include Rack::Test::Methods

  def app
    PokedexApp
  end

  describe 'GET /pokemon/:name' do
    context 'when pokemon exists' do
      before do
        stub_request(:get, 'https://pokeapi.co/api/v2/pokemon-species/mewtwo')
          .to_return(
            status: 200,
            body: {
              name: 'mewtwo',
              is_legendary: true,
              habitat: { name: 'rare' },
              flavor_text_entries: [
                {
                  flavor_text: "It was created by\na scientist.",
                  language: { name: 'en' }
                }
              ]
            }.to_json
          )
      end

      it 'returns pokemon information' do
        get '/pokemon/mewtwo'

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to include('application/json')

        json = JSON.parse(last_response.body)
        expect(json['name']).to eq('mewtwo')
        expect(json['description']).to eq('It was created by a scientist.')
        expect(json['habitat']).to eq('rare')
        expect(json['isLegendary']).to be true
      end
    end

    context 'when pokemon does not exist' do
      before do
        stub_request(:get, 'https://pokeapi.co/api/v2/pokemon-species/unknown')
          .to_return(status: 404)
      end

      it 'returns 404' do
        get '/pokemon/unknown'

        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'GET /pokemon/translated/:name' do
    context 'when pokemon is legendary' do
      before do
        stub_request(:get, 'https://pokeapi.co/api/v2/pokemon-species/mewtwo')
          .to_return(
            status: 200,
            body: {
              name: 'mewtwo',
              is_legendary: true,
              habitat: { name: 'rare' },
              flavor_text_entries: [
                {
                  flavor_text: 'It was created by a scientist.',
                  language: { name: 'en' }
                }
              ]
            }.to_json
          )

        stub_request(:post, 'https://api.funtranslations.com/translate/yoda.json')
          .with(body: { text: 'It was created by a scientist.' })
          .to_return(
            status: 200,
            body: {
              contents: {
                translated: 'Created by a scientist, it was.'
              }
            }.to_json
          )
      end

      it 'returns pokemon with yoda translation' do
        get '/pokemon/translated/mewtwo'

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['description']).to eq('Created by a scientist, it was.')
      end
    end

    context 'when pokemon habitat is cave' do
      before do
        stub_request(:get, 'https://pokeapi.co/api/v2/pokemon-species/zubat')
          .to_return(
            status: 200,
            body: {
              name: 'zubat',
              is_legendary: false,
              habitat: { name: 'cave' },
              flavor_text_entries: [
                {
                  flavor_text: 'It lives in dark caves.',
                  language: { name: 'en' }
                }
              ]
            }.to_json
          )

        stub_request(:post, 'https://api.funtranslations.com/translate/yoda.json')
          .with(body: { text: 'It lives in dark caves.' })
          .to_return(
            status: 200,
            body: {
              contents: {
                translated: 'In dark caves, it lives.'
              }
            }.to_json
          )
      end

      it 'returns pokemon with yoda translation' do
        get '/pokemon/translated/zubat'

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['description']).to eq('In dark caves, it lives.')
      end
    end

    context 'when pokemon is neither legendary nor cave habitat' do
      before do
        stub_request(:get, 'https://pokeapi.co/api/v2/pokemon-species/pikachu')
          .to_return(
            status: 200,
            body: {
              name: 'pikachu',
              is_legendary: false,
              habitat: { name: 'forest' },
              flavor_text_entries: [
                {
                  flavor_text: 'It has small electric sacs.',
                  language: { name: 'en' }
                }
              ]
            }.to_json
          )

        stub_request(:post, 'https://api.funtranslations.com/translate/shakespeare.json')
          .with(body: { text: 'It has small electric sacs.' })
          .to_return(
            status: 200,
            body: {
              contents: {
                translated: 'It hast small electric sacs.'
              }
            }.to_json
          )
      end

      it 'returns pokemon with shakespeare translation' do
        get '/pokemon/translated/pikachu'

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['description']).to eq('It hast small electric sacs.')
      end
    end

    context 'when translation fails' do
      before do
        stub_request(:get, 'https://pokeapi.co/api/v2/pokemon-species/ditto')
          .to_return(
            status: 200,
            body: {
              name: 'ditto',
              is_legendary: false,
              habitat: { name: 'urban' },
              flavor_text_entries: [
                {
                  flavor_text: 'It can transform.',
                  language: { name: 'en' }
                }
              ]
            }.to_json
          )

        stub_request(:post, 'https://api.funtranslations.com/translate/shakespeare.json')
          .to_return(status: 429)
      end

      it 'returns pokemon with standard description' do
        get '/pokemon/translated/ditto'

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['description']).to eq('It can transform.')
      end
    end

    context 'when pokemon does not exist' do
      before do
        stub_request(:get, 'https://pokeapi.co/api/v2/pokemon-species/unknown')
          .to_return(status: 404)
      end

      it 'returns 404' do
        get '/pokemon/translated/unknown'

        expect(last_response.status).to eq(404)
      end
    end
  end
end
