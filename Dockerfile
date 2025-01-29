FROM ruby:3.1.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn

RUN apt-get update -qq && apt-get install -y postgresql-client

# Set up the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock, then install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Precompile assets (if in production environment)
RUN RAILS_ENV=production bundle exec rake assets:precompile

# Expose port and set the default command
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

