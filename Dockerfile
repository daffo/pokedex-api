FROM ruby:3.3-alpine

WORKDIR /app

# Install dependencies
RUN apk add --no-cache build-base

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Run the application
CMD ["bundle", "exec", "rackup", "config.ru", "-o", "0.0.0.0", "-p", "5000"]
