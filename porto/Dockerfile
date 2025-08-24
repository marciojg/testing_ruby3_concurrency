FROM ruby:3.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# roda o servidor via rackup, ouvindo na porta 4000
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "4000"]
