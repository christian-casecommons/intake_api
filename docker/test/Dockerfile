FROM ruby:2.4.0
LABEL application=intake_api_prototype
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client

ENV APP_HOME /intake_api_prototype
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME

ENV BUNDLE_PATH /ruby_gems
RUN bundle config build.nokogiri --use-system-libraries

RUN bundle install -j24

