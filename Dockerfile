FROM ubuntu:20.04
LABEL name="docker-ci"

ARG CI_TOOLS_PYPI_REPOSITORY_URL
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ENV TZ="Europe/Paris"
ENV PYTHON_VERSION 3.7
ENV PHP_VERSION 7.4
ENV PHP_SECURITY_CHECKER_VERSION 1.0.0

RUN export LC_ALL=C.UTF-8
RUN DEBIAN_FRONTEND=noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y \
    sudo \
    autoconf \
    autogen \
    language-pack-en-base \
    wget \
    zip \
    unzip \
    curl \
    sed \
    rsync \
    ssh \
    openssh-client \
    git \
    jq \
    build-essential \
    apt-utils \
    software-properties-common \
    nasm \
    libjpeg-dev \
    libpng-dev \
    libpng16-16 \
    libxml2-dev \
    libffi-dev \
    libxss1 \
    certbot

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# Chrome
RUN echo 'deb https://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/chrome.list

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        google-chrome-stable \
        fonts-ipafont-gothic \
        fonts-wqy-zenhei \
        fonts-thai-tlwg \
        fonts-kacst

ENV CHROME_BIN /usr/bin/google-chrome

# PHP
RUN add-apt-repository ppa:ondrej/php

RUN set -x \
  && apt-get update \
  && apt-get install -y php${PHP_VERSION}

  RUN apt-get install -y \
      php${PHP_VERSION}-curl \
      php${PHP_VERSION}-gd \
      php${PHP_VERSION}-dev \
      php${PHP_VERSION}-xml \
      php${PHP_VERSION}-bcmath \
      php${PHP_VERSION}-mysql \
      php${PHP_VERSION}-pgsql \
      php${PHP_VERSION}-mbstring \
      php${PHP_VERSION}-zip \
      php${PHP_VERSION}-bz2 \
      php${PHP_VERSION}-sqlite \
      php${PHP_VERSION}-soap \
      php${PHP_VERSION}-json \
      php${PHP_VERSION}-intl \
      php${PHP_VERSION}-imap \
      php${PHP_VERSION}-soap \
      php${PHP_VERSION}-imagick \
      php-memcached

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer self-update

# Official Acquia Cli
RUN set -x \
  && curl -OL https://github.com/acquia/cli/releases/latest/download/acli.phar \
  && chmod +x acli.phar \
  && mv acli.phar /usr/local/bin/acli \
  && acli self:update

# Alternative Acquia Cli
RUN set -x \
  && cd /usr/local/share \
  && git clone https://github.com/solocal-ecommerce/acquia_cli.git \
  && cd acquia_cli \
  && composer install \
  && chmod +x /usr/local/share/acquia_cli/bin/acquiacli \
  && ln -s /usr/local/share/acquia_cli/bin/acquiacli /usr/local/bin/acquiacli-dev

RUN wget https://github.com/typhonius/acquia_cli/releases/latest/download/acquiacli.phar
RUN mv acquiacli.phar /usr/local/bin/acquiacli \
    && chmod +x /usr/local/bin/acquiacli \
    && acquiacli self:update

# Twigc
RUN wget https://github.com/okdana/twigc/releases/latest/download/twigc.phar
RUN mv twigc.phar /usr/local/bin/twigc \
    && chmod +x /usr/local/bin/twigc

# Python
RUN add-apt-repository ppa:deadsnakes/ppa

RUN set -x \
    && apt-get update \
    && apt-get install -y \
        python${PYTHON_VERSION} \
        libpython${PYTHON_VERSION}-dev

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1

RUN curl -L https://bootstrap.pypa.io/get-pip.py | python3

RUN pip3 install -U \
    twine \
    setuptools \
    wheel \
    ci-tools \
    --extra-index-url ${CI_TOOLS_PYPI_REPOSITORY_URL}

# Node
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN set -x \
    && apt-get install -y \
        nodejs

# Node dependencies
RUN set -x \
    && npm i -g lighthouse

RUN set -x \
    && npm install -g pa11y-ci pa11y-ci-reporter-html --unsafe-perm=true --allow-root

# PHP Local Security Checker
RUN set -x \
  && curl -L --output /usr/local/bin/local-php-security-checker "https://github.com/fabpot/local-php-security-checker/releases/download/v${PHP_SECURITY_CHECKER_VERSION}/local-php-security-checker_${PHP_SECURITY_CHECKER_VERSION}_linux_amd64" \
  && chmod +x /usr/local/bin/local-php-security-checker

# Log versions
RUN set -x \
    && export \
    && composer -V \
    && acquiacli -V \
    && python3 --version \
    && pip3 --version \
    && pip3 list \
    && node -v \
    && php -v \
    && npm -v \
    && google-chrome --version

