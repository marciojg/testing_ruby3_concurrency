FROM ruby:3.4.5

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle

COPY . .

CMD ["bundle", "exec", "puma", "-C", "puma.rb"]
