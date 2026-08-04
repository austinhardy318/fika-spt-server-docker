FROM mcr.microsoft.com/dotnet/aspnet:9.0-bookworm-slim

RUN apt update && apt install -y --no-install-recommends \
    curl \
    aria2 \
    ca-certificates \
    unzip \
    7zip \
    cron \
    exiftool \
    jq \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

ARG SPT_VERSION=4.1.1-40743-e18bd1e
ARG FIKA_VERSION=2.4.0
ENV SPT_VERSION=$SPT_VERSION
ENV FIKA_VERSION=$FIKA_VERSION

WORKDIR /opt/build
RUN curl -fSL "https://spt-releases.modd.in/SPT-${SPT_VERSION}.7z" -o spt.7z
RUN 7zz x spt.7z

COPY entrypoint.sh /usr/bin/entrypoint
COPY scripts/backup.sh /usr/bin/backup
COPY scripts/download_unzip_install_mods.sh /usr/bin/download_unzip_install_mods
COPY data/cron/cron_backup_spt /etc/cron.d/cron_backup_spt
RUN dos2unix /usr/bin/entrypoint /usr/bin/backup /usr/bin/download_unzip_install_mods /etc/cron.d/cron_backup_spt && \
    chmod +x /usr/bin/entrypoint /usr/bin/backup /usr/bin/download_unzip_install_mods /etc/cron.d/cron_backup_spt

# Docker desktop doesn't allow you to configure port mappings unless this is present
EXPOSE 6969
HEALTHCHECK --interval=30s --timeout=5s --start-period=180s --retries=3 \
  CMD curl -fk https://127.0.0.1:6969/launcher/server/version || exit 1
ENTRYPOINT ["/usr/bin/entrypoint"]
