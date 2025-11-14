# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'httparty'
require_relative 'lib/pokemon_service'
require_relative 'lib/translation_service'

class PokedexApp < Sinatra::Base
  get '/pokemon/:name' do
  content_type :json

  pokemon = PokemonService.fetch_pokemon(params[:name])

  halt 404 unless pokemon

  pokemon.to_json
end

get '/pokemon/translated/:name' do
  content_type :json

  pokemon = PokemonService.fetch_pokemon(params[:name])

  halt 404 unless pokemon

  translation_type = compute_translation_type(pokemon)
  pokemon[:description] = TranslationService.translate(pokemon[:description], translation_type)

  pokemon.to_json
end

  def compute_translation_type(pokemon)
    if pokemon[:habitat] == 'cave' || pokemon[:isLegendary]
      :yoda
    else
      :shakespeare
    end
  end
end
