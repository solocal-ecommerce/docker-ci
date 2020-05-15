FROM ubuntu:18.04
LABEL name="docker-ci"

ENV TZ="Europe/Paris"

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
    rsync \
    ssh \
    openssh-client \
    git \
    build-essential \
    apt-utils \
    software-properties-common \
    nasm \
    libjpeg-dev \
    libpng-dev \
    libpng16-16 \
    libxml2-dev \
    libffi-dev

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# Certbot

RUN add-apt-repository universe
    && add-apt-repository ppa:certbot/certbot 

RUN set -x \
    && apt-get update
    && apt-get install -y certbot

# Chrome
RUN echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/chrome.list

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

RUN set -x \
    && apt-get update \
    && apt-get install -y \
        google-chrome-stable

ENV CHROME_BIN /usr/bin/google-chrome

# PHP
ENV PHP_VERSION 7.3

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
    && composer self-update --preview

# Acquia Cli
RUN wget https://github.com/typhonius/acquia_cli/releases/latest/download/acquiacli.phar
RUN mv acquiacli.phar /usr/local/bin/acquiacli \
    && chmod +x /usr/local/bin/acquiacli \
    && acquiacli self:update

# Python
ENV PYTHON_VERSION 3.7

RUN add-apt-repository ppa:deadsnakes/ppa

RUN set -x \
    && apt-get update \
    && apt-get install -y \
        python${PYTHON_VERSION} \
        libpython${PYTHON_VERSION}-dev \
        python3-pip

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1

RUN pip3 install \
      requests \
      urllib3 \
      pyOpenSSL \
      docopt \
      slackclient \
      jira \
      GitPython \
      acapi \
      psutil \
      requests_mock \
      aioresponses \
      twine \
      setuptools \
      wheel

# Node
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN set -x \
    && apt-get install -y \
        nodejs

# Node dependencies
RUN set -x \
    && npm i -g lighthouse \
    && npm i -g --unsafe-perm node-sass

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
