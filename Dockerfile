#FROM ruby:2.6-alpine
FROM ruby:alpine

LABEL maintainer "James Clarke <james@clarkezone.net>"

# --
# EnvVars
# Ruby
# --

ENV BUNDLE_HOME=/usr/local/bundle
ENV BUNDLE_APP_CONFIG=/usr/local/bundle
ENV BUNDLE_BIN=/usr/local/bundle/bin
ENV GEM_BIN=/usr/gem/bin
ENV GEM_HOME=/usr/gem

# --
# EnvVars
# Image
# --
ENV JEKYLL_VAR_DIR=/var/jekyll
ENV JEKYLL_DATA_DIR=/srv/jekyll
ENV JEKYLL_BIN=/usr/jekyll/bin
ENV JEKYLL_ENV=development

# --
# EnvVars
# System
# --
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV TZ=America/Chicago
ENV PATH="$JEKYLL_BIN:$PATH"
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US

# --
# EnvVars
# User
# --

ENV JEKYLL_ENV=production

# --
# EnvVars
# Main
# --
ENV VERBOSE=false
ENV FORCE_POLLING=false
ENV DRAFTS=false

# --
# Packages
# User
# --
RUN apk --no-cache add \
  rsync \
  openssh-client \
  lftp \
  git

# --
# Packages
# Dev
# --
RUN apk --no-cache add \
  zlib-dev \
  build-base \
  libxml2-dev \
  libxslt-dev \
  readline-dev \
  libffi-dev \
  yaml-dev \
  zlib-dev \
  libffi-dev \
  cmake

# --
# Packages
# Main
# --
RUN apk --no-cache add \
  linux-headers \
  openjdk8-jre \
  less \
  zlib \
  libxml2 \
  readline \
  libxslt \
  libffi \
  git \
  nodejs \
  tzdata \
  shadow \
  bash \
  su-exec \
  nodejs-npm \
  libressl \
  yarn

# --
# Gems
# Update
# --
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN unset GEM_HOME && unset GEM_BIN && \
  yes | gem update --system

# --
# Gems
# Main
# --
# Work around a nonsense RubyGem permission bug.
RUN unset GEM_HOME && unset GEM_BIN && yes | gem install --force bundler
RUN gem install jekyll -v 4.0.0 -- --use-system-libraries

# --
# Gems
# User
# --

# Stops slow Nokogiri!
RUN gem install s3_website \
  html-proofer \
  jekyll-sitemap \
  jekyll-mentions \
  jekyll-coffeescript \
  jekyll-sass-converter \
  jekyll-redirect-from \
  jekyll-paginate \
  jekyll-compose \
  jekyll-feed \
  jekyll-docs \
  RedCloth \
  kramdown \
  jemoji \
  minima \
  github-pages \
  jekyll-github-metadata \
  -- --use-system-libraries

# --
# Remove development packages on minimal.
# And on pages.  Gems are unsupported.
# --
RUN apk --no-cache del \
  linux-headers \
  openjdk8-jre \
  zlib-dev \
  build-base \
  libxml2-dev \
  libxslt-dev \
  readline-dev \
  libffi-dev \
  ruby-dev \
  yaml-dev \
  zlib-dev \
  libffi-dev \
  cmake

# --
RUN mkdir -p $JEKYLL_VAR_DIR
RUN mkdir -p $JEKYLL_DATA_DIR

# --
RUN rm -rf /root/.gem
RUN rm -rf /home/jekyll/.gem
RUN rm -rf $BUNDLE_HOME/cache
RUN rm -rf $GEM_HOME/cache

# --
CMD ["jekyll", "--help"]
# ENTRYPOINT ["/bin/sh"]
ENTRYPOINT ["/usr/jekyll/bin/entrypoint"]
WORKDIR /srv/jekyll
VOLUME  /srv/jekyll
EXPOSE 35729
EXPOSE 4000
