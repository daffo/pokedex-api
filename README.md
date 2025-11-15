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

## Production Considerations

### Technology Choice

The language/framework choice (Ruby with Sinatra) was purely for simplicity and personal knowledge. In a real production environment, the webapp choice would vary based on team structure and expertise.

### Error Handling

Currently, external API errors are silently ignored. This is unacceptable in production. A real implementation would require:
- Comprehensive logging for all external API failures
- Alerting system to notify the team of degraded service

### Monitoring

Production systems need comprehensive metrics for both infrastructure health and service health:
- Logs in Elastic for searchability
- SLI/SLO definitions and tracking
- Datadog dashboards for error monitoring and alerting

### Testing

While this implementation includes unit tests and integration tests, it lacks contract testing with external APIs. Production systems should implement contract tests to verify that external API responses match our expectations and detect breaking changes early.

Additionally, production deployments typically include a set of smoke tests to guarantee the system is healthy after deployment.

### Caching

This data can be considered extremely static. Depending on how much we want to invest in cache size, we can use very long TTL values:
- Translations: multiple days (highly static)
- Pokemon descriptions: might change more often, but stale data is a minor inconvenience rather than a major problem

### Rate Limiting

If the REST endpoints are completely public without any authentication or at least a captcha, we should implement a throttle limiter to prevent abuse and protect the service from excessive load.

### Secret Management

For non-free APIs (like the translation service), we need to purchase a plan and obtain API keys. API keys must never be hardcoded as plain strings in the code. A production system requires a vault system to securely store secrets and inject them into the environment.

### Documentation

A README is not sufficient for production APIs. We should set up comprehensive documentation for our APIs using standards like OpenAPI/Swagger to provide interactive documentation, request/response schemas, and client code generation capabilities.

### API Versioning

Production APIs should implement versioning to allow for breaking changes without disrupting existing clients. A common pattern (exactly what PokéAPI does) is to include `/vX/` in the URL path (e.g., `/v1/pokemon/mewtwo`).

### Infrastructure

Production deployments require proper CI/CD pipelines and hosting infrastructure. I have experience as a user with GitHub Actions and pipelines for CI, Kubernetes for CD, and AWS for hosting, though I lack deep expertise in configuring these systems from scratch.

## External APIs

- [PokéAPI](https://pokeapi.co/) - Pokémon data
- [FunTranslations API](https://funtranslations.com/) - Shakespeare/Yoda translations (rate limited: 5 requests/hour on free tier)
