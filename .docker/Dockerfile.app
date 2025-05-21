FROM ruby:3.4.3-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      fping \
      netbase \
      build-essential \
      postgresql-client \
      libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs $(nproc)

COPY . .
