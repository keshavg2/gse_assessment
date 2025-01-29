# Use official Ruby image
FROM ruby:3.0.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y postgresql-client

# Set up working directory
WORKDIR /app
COPY . /app

# Install Gems
RUN bundle install

# Precompile assets
RUN RAILS_ENV=production bundle exec rake assets:precompile

# Expose the app on port 3000
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
