FROM freshrss/freshrss:1.28.0
LABEL maintainer="la3rence"

RUN apt-get update && \
    apt-get install -y git rclone && \
    rm -rf /var/lib/apt/lists/*

# rclone cron backup script
COPY backup.sh /usr/local/bin/freshrss-backup.sh
RUN chmod +x /usr/local/bin/freshrss-backup.sh && \
    echo "0 3 * * * root /usr/local/bin/freshrss-backup.sh >> /var/log/backup.log 2>&1" \
    > /etc/cron.d/freshrss-backup && \
    chmod 0644 /etc/cron.d/freshrss-backup && \
    crontab /etc/cron.d/freshrss-backup

WORKDIR /tmp

RUN git clone https://github.com/FreshRSS/Extensions --depth=1 && \
    git clone https://codeberg.org/javerous/freshrss-greader-redate.git --depth=1 && \
    git clone https://github.com/jacob2826/FreshRSS-TranslateTitlesCN --depth=1 && \
    git clone https://github.com/la3rence/xExtension-ArticleSummary --depth=1

RUN cp -r Extensions/xExtension-ImageProxy /var/www/FreshRSS/extensions/ && \
    cp -r Extensions/xExtension-ReadingTime /var/www/FreshRSS/extensions/ && \
    cp -r freshrss-greader-redate/xExtension-GReaderRedate /var/www/FreshRSS/extensions/ && \
    cp -r FreshRSS-TranslateTitlesCN/TranslateTitlesCN /var/www/FreshRSS/extensions/ && \
    cp -r xExtension-ArticleSummary /var/www/FreshRSS/extensions/ && \
    rm -rf /tmp/*

WORKDIR /var/www/FreshRSS
