# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Default to production-friendly settings; override at runtime if needed
ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle

# Update system and install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy application files
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --jobs 4 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Make all scripts executable
RUN chmod +x /rails/bin/*

# Precompile assets for production (uses dummy secret key)
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

EXPOSE 3000

# Default command: Puma via Rails config
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
