FROM ruby:2.5-alpine

RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git

# Get bundle config with creds
COPY .bundle/config /root/.bundle/config
COPY geminabox /root/.gem/geminabox

ENV APP_PATH /opt/app
WORKDIR $APP_PATH

COPY . $APP_PATH/

WORKDIR $APP_PATH/

RUN bundle install
