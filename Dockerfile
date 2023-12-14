FROM freshrss/freshrss:1.22.1

RUN apt-get update && \
  apt-get install -y git && \
  rm -rf /var/lib/apt/lists/*
  
WORKDIR /tmp

RUN git clone https://github.com/FreshRSS/Extensions --depth=1

RUN cp -r Extensions/xExtension-ImageProxy /var/www/FreshRSS/extensions/ && \
  rm -rf /tmp/Extensions

WORKDIR /var/www/FreshRSS