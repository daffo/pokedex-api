# Pokedex API

A REST API that returns Pokémon information with fun translations (Shakespeare/Yoda).

## Requirements

- Ruby 3.0+ and Bundler, OR
- Docker

## Installation & Running

### With Ruby

```bash
bundle install
bundle exec rackup config.ru -p 5000
```

### With Docker

```bash
docker build -t pokedex-api .
docker run -p 5000:5000 pokedex-api
```

API runs at `http://localhost:5000`

## API Endpoints

### GET /pokemon/:name

Returns basic Pokémon information.

**Example:**
```bash
curl http://localhost:5000/pokemon/mewtwo
```

**Response:**
```json
{
  "name": "mewtwo",
  "description": "It was created by a scientist after years of horrific gene splicing and DNA engineering experiments.",
  "habitat": "rare",
  "isLegendary": true
}
```

### GET /pokemon/translated/:name

Returns Pokémon information with translated description.

**Translation Rules:**
- Yoda translation: if habitat is `cave` OR Pokémon is legendary
- Shakespeare translation: all other Pokémon
- Falls back to standard description if translation fails

**Example:**
```bash
curl http://localhost:5000/pokemon/translated/mewtwo
```

**Response:**
```json
{
  "name": "mewtwo",
  "description": "Created by a scientist after years of horrific gene splicing and dna engineering experiments, it was.",
  "habitat": "rare",
  "isLegendary": true
}
```

## Running Tests

```bash
bundle exec rspec
```

## External APIs

- [PokéAPI](https://pokeapi.co/) - Pokémon data
- [FunTranslations API](https://funtranslations.com/) - Shakespeare/Yoda translations (rate limited: 5 requests/hour on free tier)
