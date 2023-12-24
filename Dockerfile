FROM freshrss/freshrss:1.23.0
MAINTAINER la3rence

RUN apt-get update && \
  apt-get install -y git && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN git clone https://github.com/FreshRSS/Extensions --depth=1 && \
  git clone https://github.com/javerous/freshrss-greader-redate --depth=1 && \
  git clone https://github.com/reply2future/xExtension-NewsAssistant --depth=1 && \
  git clone https://github.com/jacob2826/FreshRSS-TranslateTitlesCN --depth=1

RUN cp -r Extensions/xExtension-ImageProxy /var/www/FreshRSS/extensions/ && \
  cp -r Extensions/xExtension-ReadingTime /var/www/FreshRSS/extensions/ && \
  cp -r freshrss-greader-redate/xExtension-GReaderRedate /var/www/FreshRSS/extensions/ && \
  cp -r FreshRSS-TranslateTitlesCN/TranslateTitlesCN /var/www/FreshRSS/extensions/ && \
  mkdir -p /var/www/FreshRSS/extensions/xExtension-NewsAssistant && \
  cp -r xExtension-NewsAssistant/* /var/www/FreshRSS/extensions/xExtension-NewsAssistant/ && \
  rm -rf /tmp/*

WORKDIR /var/www/FreshRSS