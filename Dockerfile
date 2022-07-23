#
# Builder image
#   = Ruby + build-essential(gcc/g++) for native extensions
#     + Node.js for webpack
#
FROM node:16.16.0-slim as node
FROM ruby:3.1.2 as builder

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn

WORKDIR /app

# Copy source code
COPY . /app

# Ruby gem packages
RUN bundle install

# Node.js packages & webpack
RUN yarn install
RUN /app/bin/rails webpacker:compile && \
    /app/bin/rails assets:precompile

# Create runtime distribution
RUN mkdir -p /dist && \
    cp -pr Gemfile Gemfile.lock Rakefile config.ru app bin config db lib public \
    /dist/

#
# Runtime image
#
FROM ruby:3.1.2-slim

RUN apt-get update && apt-get install -y \
    libpq-dev \
    default-libmysqlclient-dev \
    sqlite3 # postgresql-client default-mysql-client

WORKDIR /app
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /dist /app
RUN mkdir /app/storage && mkdir /app/tmp && mkdir /app/log

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["/app/bin/rails", "server", "-b", "0.0.0.0"]
