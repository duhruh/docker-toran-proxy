FROM ubuntu:14.04

# Install tools software
RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-get update -qq \
 && apt-get install -qqy \
    vim.tiny \
    curl \
    wget \
    net-tools \
    ca-certificates \
    unzip

# Clean
RUN rm -rf /var/lib/apt/lists/*


# Install supervisor
RUN apt-get update -qq \
    && apt-get install -qqy supervisor

# Install ssh
RUN apt-get update -qq \
    && apt-get install -qqy ssh

# Install PHP and Nginx
RUN apt-get update -qq \
    && apt-get install -qqy \
        git \
        apt-transport-https \
        daemontools \
        php5-fpm \
        php5-json \
        php5-cli \
        php5-intl \
        php5-curl \
        nginx

# Configure PHP and Nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Version Toran Proxy
ENV TORAN_PROXY_VERSION 1.5.1

# Download Toran Proxy
RUN curl -sL https://toranproxy.com/releases/toran-proxy-v${TORAN_PROXY_VERSION}.tgz | tar xzC /tmp \
    && mv /tmp/toran /var/www

# Load Scripts bash for installing Toran Proxy
COPY scripts /scripts/toran-proxy/
RUN chmod -R u+x /scripts/toran-proxy

# Load binaries
COPY bin /bin/toran-proxy/
RUN chmod -R u+x /bin/toran-proxy
ENV PATH $PATH:/bin/toran-proxy

# Load assets
COPY assets/supervisor/conf.d /etc/supervisor/conf.d
COPY assets/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY assets/vhosts /etc/nginx/sites-available
COPY assets/config /assets/config

# Clean
RUN rm -rf /var/lib/apt/lists/*

VOLUME /data/toran-proxy

EXPOSE 80
EXPOSE 443

CMD /scripts/toran-proxy/launch.sh
