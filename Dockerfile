FROM freshrss/freshrss:1.22.1

WORKDIR /tmp

RUN apk add --no-cache git && \
  git clone https://github.com/FreshRSS/Extensions --depth=1

RUN cp -r Extensions/xExtension-ImageProxy /var/www/FreshRSS/extensions/ && \
  rm -rf /tmp/Extensions

WORKDIR /var/www/FreshRSS